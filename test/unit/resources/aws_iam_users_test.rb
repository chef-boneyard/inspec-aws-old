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
    user_list = [{name: "test1", has_mfa_enabled?: true},
    {name: "test2", has_mfa_enabled?: true},
    {name: "test3", has_mfa_enabled?: true}]

    mock_user_1 = Minitest::Mock.new
    mock_user_1.expect :has_mfa_enabled?, user_list[0][:has_mfa_enabled?]

    mock_user_2 = Minitest::Mock.new
    mock_user_2.expect :has_mfa_enabled?, user_list[1][:has_mfa_enabled?]

    mock_user_3 = Minitest::Mock.new
    mock_user_3.expect :has_mfa_enabled?, user_list[2][:has_mfa_enabled?]

    @mock_user_provider.expect :list_users, user_list
    @mock_user_provider.expect :nil?, false
    @mock_user_factory.expect :create_user, mock_user_1, [user_list[0]]
    @mock_user_factory.expect :create_user, mock_user_2, [user_list[1]]
    @mock_user_factory.expect :create_user, mock_user_3, [user_list[2]]
    user_collection = AwsIamUsers.new(@mock_user_provider, @mock_user_factory)
    user_collection.users.each do |user| 
      assert user.has_mfa_enabled?
    end
  end

end