require '_aws'

# author: Alex Bedley
# author: Steffanie Freeman
# author: Simon Varlow
# author: Chris Redekop
class AwsIamUser < Inspec.resource(1)
  name 'aws_iam_user'
  desc 'Verifies settings for AWS IAM user'
  example "
    describe aws_iam_user(username: 'test_user') do
      it { should have_mfa_enabled }
      it { should_not have_console_password }
    end
  "

  include AwsResourceMixin
  attr_reader :username, :has_mfa_enabled, :has_console_password, :access_keys
  alias has_mfa_enabled? has_mfa_enabled
  alias has_console_password? has_console_password

  def name
    warn "[DEPRECATION] - Property ':name' is deprecated on the aws_iam_user resource.  Use ':username' instead."
    username
  end

  def to_s
    "IAM User #{username}"
  end

  private

  def validate_params(raw_params)
    validated_params = check_resource_param_names(
      raw_params: raw_params,
      allowed_params: [:username, :aws_user_struct, :name, :user],
      allowed_scalar_name: :username,
      allowed_scalar_type: String,
    )
    # If someone passed :name, rename it to :username
    if validated_params.key?(:name)
      warn "[DEPRECATION] - Resource parameter ':name' is deprecated on the aws_iam_user resource.  Use ':username' instead."
      validated_params[:username] = validated_params.delete(:name)
    end

    # If someone passed :user, rename it to :aws_user_struct
    if validated_params.key?(:user)
      warn "[DEPRECATION] - Resource parameter ':user' is deprecated on the aws_iam_user resource.  Use ':aws_user_struct' instead."
      validated_params[:aws_user_struct] = validated_params.delete(:user)
    end

    if validated_params.empty?
      raise ArgumentError, 'You must provide a username to aws_iam_user.'
    end
    validated_params
  end

  def fetch_from_aws
    backend = BackendFactory.create
    @aws_user_struct ||= nil # silence unitialized warning
    unless @aws_user_struct
      begin
        @aws_user_struct = backend.get_user(user_name: username)
      rescue Aws::IAM::Errors::NoSuchEntity
        @exists = false
        return
      end
    end
    # TODO: extract properties from aws_user_struct?

    @exists = true

    begin
      _login_profile = backend.get_login_profile(user_name: username)
      @has_console_password = true
      # Password age also available here
    rescue Aws::IAM::Errors::NoSuchEntity
      @has_console_password = false
    end

    mfa_info = backend.list_mfa_devices(user_name: username)
    @has_mfa_enabled = !mfa_info.mfa_devices.empty?

    # TODO: consider returning Inspec AwsIamAccessKey objects
    @access_keys = backend.list_access_keys(user_name: username).access_key_metadata
  end

  class Backend
    class AwsClientApi
      BackendFactory.set_default_backend(self)

      def get_user(criteria)
        AWSConnection.new.iam_client.get_user(criteria)
      end

      def get_login_profile(criteria)
        AWSConnection.new.iam_client.get_login_profile(criteria)
      end

      def list_mfa_devices(criteria)
        AWSConnection.new.iam_client.list_mfa_devices(criteria)
      end

      def list_access_keys(criteria)
        AWSConnection.new.iam_client.list_access_keys(criteria)
      end
    end
  end
end
