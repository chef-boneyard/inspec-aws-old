module AwsIam
  class UserDetailsProvider
    def user(user)
      @aws_user = user
    end

    def has_mfa_enabled?
      !@aws_user.mfa_devices.first.nil?
    end

    def has_console_password?
      return !@aws_user.login_profile.create_date.nil?
    rescue Aws::IAM::Errors::NoSuchEntity
      return false
    end

    def access_keys
      @aws_user.access_keys
    end

    def convert
      {
        has_mfa_enabled?: has_mfa_enabled?,
        has_console_password?: has_console_password?,
        access_keys: access_keys,
      }
    end
  end
end
