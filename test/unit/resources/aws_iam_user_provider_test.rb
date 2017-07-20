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

  def test_has_mfa_enabled_returns_true
    @mock_iam_resource_user.expect :mfa_devices, ['device']
    @mock_iam_resource.expect :user, @mock_iam_resource_user, [Username]
    assert AwsIam::UserProvider.has_mfa_enabled?(@mock_iam_resource_user)
  end

  def test_has_mfa_enabled_returns_false
    @mock_iam_resource_user.expect :mfa_devices, []
    @mock_iam_resource.expect :user, @mock_iam_resource_user, [Username]
    assert !AwsIam::UserProvider.has_mfa_enabled?(@mock_iam_resource_user)
  end

  def test_has_console_password_returns_true
    mock_login_profile = Minitest::Mock.new
    mock_login_profile.expect :create_date, 'date'
    @mock_iam_resource_user.expect :login_profile, mock_login_profile
    @mock_iam_resource.expect :user, @mock_iam_resource_user, [Username]
    assert AwsIam::UserProvider.has_console_password?(@mock_iam_resource_user)
  end

  def test_has_console_password_returns_false
    mock_login_profile = Minitest::Mock.new
    mock_login_profile.expect :create_date, nil
    @mock_iam_resource_user.expect :login_profile, mock_login_profile
    @mock_iam_resource.expect :user, @mock_iam_resource_user, [Username]
    assert !AwsIam::UserProvider.has_console_password?(@mock_iam_resource_user)
  end

  def test_has_console_password_returns_false_when_nosuchentity
    mock_login_profile = Minitest::Mock.new
    mock_login_profile.expect :create_date, nil do |args|
      raise Aws::IAM::Errors::NoSuchEntity.new(nil, nil)
    end
    @mock_iam_resource_user.expect :login_profile, mock_login_profile
    @mock_iam_resource.expect :user, @mock_iam_resource_user, [Username]
    
    assert !AwsIam::UserProvider.has_console_password?(@mock_iam_resource_user)
  end

  def test_has_console_password_throws
    mock_login_profile = Minitest::Mock.new
    mock_login_profile.expect :create_date, nil do |args|
      raise ArgumentError
    end
    @mock_iam_resource_user.expect :login_profile, mock_login_profile
    @mock_iam_resource.expect :user, @mock_iam_resource_user, [Username]
    
    assert_raises ArgumentError do
      AwsIam::UserProvider.has_console_password?(@mock_iam_resource_user)
    end
  end

  def test_access_keys_returns_access_keys
    access_key = Object.new
    @mock_iam_resource_user.expect :access_keys, [access_key]
    @mock_iam_resource.expect :user, @mock_iam_resource_user, [Username]

    assert_equal [access_key], AwsIam::UserProvider.access_keys(@mock_iam_resource_user)
  end

  private

  def create_mock_user(has_console_password: true, has_mfa_enabled: true,
                       access_keys: [])
    mock_login_profile = Minitest::Mock.new
    mock_login_profile.expect :create_date, has_console_password ? 'date' : nil

    mock_user = Minitest::Mock.new
    mock_user.expect :name, Username
    mock_user.expect :mfa_devices, has_mfa_enabled ? ['device'] : []
    mock_user.expect :login_profile, mock_login_profile
    mock_user.expect :access_keys, access_keys
  end

  def create_mock_user_throw(exception)
    mock_login_profile = Minitest::Mock.new
    mock_login_profile.expect :create_date, nil do
      raise exception
    end

    mock_user = Minitest::Mock.new
    mock_user.expect :name, Username
    mock_user.expect :mfa_devices, []
    mock_user.expect :login_profile, mock_login_profile
    mock_user.expect :access_keys, []
  end
end
