require '_aws'

# author: Alex Bedley
# author: Steffanie Freeman
# author: Simon Varlow
# author: Chris Redekop
class AwsIamUsers < Inspec.resource(1)
  name 'aws_iam_users'
  desc 'Verifies settings for AWS IAM users'
  example '
    describe aws_iam_users.where(has_mfa_enabled?: false) do
      it { should_not exist }
    end
    describe aws_iam_users.where(has_console_password?: true) do
      it { should exist }
    end
  '
  supports platform: 'aws'

  include AwsPluralResourceMixin

  filter = FilterTable.create
  filter.add_accessor(:where)
        .add_accessor(:entries)
        .add(:exists?) { |x| !x.entries.empty? }
        .add(:has_mfa_enabled?, field: :has_mfa_enabled)
        .add(:has_console_password?, field: :has_console_password)
        .add(:password_ever_used?, field: :password_ever_used?)
        .add(:password_never_used?, field: :password_never_used?)
        .add(:password_last_used_days_ago, field: :password_last_used_days_ago)
        .add(:username, field: :user_name)
  filter.connect(self, :table)

  def validate_params(raw_params)
    # No params yet
    unless raw_params.empty?
      raise ArgumentError, 'aws_iam_users does not accept resource parameters'
    end
    raw_params
  end

  def fetch_from_api
    backend = BackendFactory.create(inspec_runner)
    @table = backend.list_users.users.map(&:to_h)

    # TODO: lazy columns - https://github.com/chef/inspec-aws/issues/100
    @table.each do |user|
      begin
        _login_profile = backend.get_login_profile(user_name: user[:user_name])
        user[:has_console_password] = true
      rescue Aws::IAM::Errors::NoSuchEntity
        user[:has_console_password] = false
      end
      user[:has_console_password?] = user[:has_console_password]

      begin
        aws_mfa_devices = backend.list_mfa_devices(user_name: user[:user_name])
        user[:has_mfa_enabled] = !aws_mfa_devices.mfa_devices.empty?
      rescue Aws::IAM::Errors::NoSuchEntity
        user[:has_mfa_enabled] = false
      end
      user[:has_mfa_enabled?] = user[:has_mfa_enabled]
      password_last_used = user[:password_last_used]
      user[:password_ever_used?] = !password_last_used.nil?
      user[:password_never_used?] = password_last_used.nil?
      next unless user[:password_ever_used?]
      user[:password_last_used_days_ago] = ((Time.now - password_last_used) / (24*60*60)).to_i
    end
    @table
  end

  def to_s
    'IAM Users'
  end

  #===========================================================================#
  #                        Backend Implementation
  #===========================================================================#
  class Backend
    class AwsClientApi < AwsBackendBase
      BackendFactory.set_default_backend(self)
      self.aws_client_class = Aws::IAM::Client

      # TODO: delegate this out
      def list_users(query = {})
        aws_service_client.list_users(query)
      end

      def get_login_profile(query)
        aws_service_client.get_login_profile(query)
      end

      def list_mfa_devices(query)
        aws_service_client.list_mfa_devices(query)
      end
    end
  end
end
