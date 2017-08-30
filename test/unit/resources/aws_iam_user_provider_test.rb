# author: Simon Varlow
# author: Jeffrey Lyons
# author: Steffanie Freeman
# author: Alex Bedley
require 'aws-sdk'
require 'helper'
require 'aws_iam_user_provider'

class AwsIamUserProviderTest < Minitest::Test
  Username = 'test'.freeze

  def setup
    @mock_iam_resource = Minitest::Mock.new
    @mock_aws_connection = Minitest::Mock.new
    @mock_aws_connection.expect :iam_resource, @mock_iam_resource
    @user_provider = AwsIam::UserProvider.new(@mock_aws_connection)
    @mock_iam_resource_user = Minitest::Mock.new
  end

  def test_user
    @mock_iam_resource_user.expect :nil?, false
    @mock_iam_resource.expect :user, @mock_iam_resource_user, [Username]
    assert !@user_provider.user(Username).nil?
  end

  def test_list_users
    @mock_iam_resource.expect :users, [Username, Username, Username]
    assert @user_provider.list_users == [Username, Username, Username]
  end

  def test_list_users_no_users
    @mock_iam_resource.expect :users, []
    assert @user_provider.list_users == []
  end
end
