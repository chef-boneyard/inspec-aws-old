# author: Alex Bedley
# author: Steffanie Freeman
# author: Simon Varlow
# author: Chris Redekop
class AwsIamUsers < Inspec.resource(1)
  name 'aws_iam_users'
  desc 'Verifies settings for AWS IAM users'
  example ''

  filter = FilterTable.create
  filter.add_accessor(:where)
        .add_accessor(:entries)
        .add(:exists?) { |x| !x.entries.empty? }
  filter.connect(self, :collect_user_details)

  def initialize(aws_user_provider = AwsIam::UserProvider.new,
                 user_factory = AwsIamUserFactory.new)
    @user_provider = aws_user_provider
    @user_factory = user_factory
  end

  def collect_user_details
    @users_cache ||= @user_provider.list_users unless @user_provider.nil?
  end

  def users
    users = []
    users ||= @user_provider.list_users unless @user_provider.nil?
    users.map { |user|
      @user_factory.create_user(user)
    }
  end

  def to_s
    'IAM Users'
  end

  class AwsIamUserFactory
    def create_user(user)
      AwsIamUser.new(user: user)
    end
  end
end
