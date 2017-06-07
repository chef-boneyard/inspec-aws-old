# author: Adnan Duric
# author: Steffanie Freeman
require 'aws-sdk'
require 'helper'
require 'aws_iam_users'

class AwsIamUsersTest < Minitest::Test
  def setup
    @mock_user_provider = Minitest::Mock.new
    @mock_user_factory = Minitest::Mock.new
  end

  def test_mfa_enabled_returns_true_for_all_users_if_mfa_enabled
    user = create_mock_user()
    user_2 = create_mock_user()
    user_list = [user, user_2]

    @mock_user_provider.expect :list_users, user_list
    @mock_user_provider.expect :nil?, false

    user_collection = AwsIamUsers.new(@mock_user_provider, @mock_user_factory)
    user_collection.users.each do |user| 
      assert user.has_mfa_enabled?
    end
  end

  def test_nil_user_provider_returns_empty_list
    user_collection = AwsIamUsers.new(nil, @mock_user_factory)
    assert_equal(user_collection.users,[])
  end

  def test_empty_list_user_provider_returns_empty_list
    user_list = []
    @mock_user_provider.expect :list_users, user_list
    @mock_user_provider.expect :nil?, false
    user_collection = AwsIamUsers.new(@mock_user_provider, @mock_user_factory)
    assert_equal(user_collection.users,[])
  end

  def create_mock_user(has_console_password: true, has_mfa_enabled: true)
    mock_user = Minitest::Mock.new
    mock_user.expect :has_console_password, has_console_password
    mock_user.expect :has_mfa_enabled, has_mfa_enabled
  end
end
