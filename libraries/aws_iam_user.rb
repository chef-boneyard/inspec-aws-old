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

  # This is lifted directly from resource_mixin.rb; delete after PR 121 merges
  def initialize(resource_params)
    validate_params(resource_params).each do |param, value|
      instance_variable_set(:"@#{param}", value)
    end
    fetch_from_aws
  end

  # This is lifted directly from resource_mixin.rb; delete after PR 121 merges
  def check_resource_param_names(raw_params: {}, allowed_params: [], allowed_scalar_name: nil, allowed_scalar_type: nil)
    # Some resources allow passing in a single ID value.  Check and convert to hash if so.
    if allowed_scalar_name && !raw_params.is_a?(Hash)
      value_seen = raw_params
      if value_seen.is_a?(allowed_scalar_type)
        raw_params = { allowed_scalar_name => value_seen }
      else
        raise ArgumentError, 'If you pass a single value to the resource, it must ' \
                             "be a #{allowed_scalar_type}, not an #{value_seen.class}."
      end
    end

    # Remove all expected params from the raw param hash
    validated_params = {}
    allowed_params.each do |expected_param|
      validated_params[expected_param] = raw_params.delete(expected_param) if raw_params.key?(expected_param)
    end

    # Any leftovers are unwelcome
    unless raw_params.empty?
      raise ArgumentError, "Unrecognized resource param '#{raw_params.keys.first}'. Expected parameters: #{allowed_params.join(', ')}"
    end

    validated_params
  end

  attr_reader :username, :has_mfa_enabled, :has_console_password, :access_keys
  alias has_mfa_enabled? has_mfa_enabled
  alias has_console_password? has_console_password

  # This is lifted directly from resource_mixin.rb; delete after PR 121 merges
  def exists?
    @exists
  end

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

  # This class may be deleted once PR 121 is merged.
  class BackendFactory
    def self.create
      @selected_backend.new
    end

    def self.select(klass)
      @selected_backend = klass
    end
  end

  class Backend
    class AwsClientApi
      BackendFactory.select(self) # TODO: correct to set_default_backend when 121 merges

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
