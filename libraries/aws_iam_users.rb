# author: Alex Bedley
# author: Steffanie Freeman
class AwsIamUsers < Inspec.resource(1)
  name 'aws_iam_users'
  desc 'Verifies settings for AWS IAM users'
  example ''

    filter = FilterTable.create
    filter.add_accessor(:where)
          .add_accessor(:entries)
          .add(:user_name, field: :username)
          .add(:has_mfa_enabled?)
          .add(:has_console_password?)
    filter.connect(self, :collect_user_details)

  def initialize(aws_user_provider = AwsIam::UserProvider.new,
                 user_factory = AwsIamUserFactory.new)
    @user_provider = aws_user_provider
    @user_factory = user_factory
  end

  def collect_user_details
<<<<<<< 862ab67b3707ee4fa61ef05fccf8ccd1abdd5b1a
    @users_cache ||= @user_provider.list_users unless @user_provider.nil?
  end

=======
    @users_cache ||= @user_provider.collect_user_details unless @user_provider.nil?
  end
  
>>>>>>> Adding Filter table and Collect User Details to aws_iam_users.rb
  def users
    users = []
    users ||= @user_provider.list_users unless @user_provider.nil?

    users.map { |user|
      @user_factory.create_user(user)
    }
  end

  class AwsIamUserFactory
    def create_user(user)
      AwsIamUser.new(user: user)
    end
  end
end
