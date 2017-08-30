# author: Steffanie Freeman
# author: Adnan Duric
require 'aws-sdk'
require 'helper'
require 'aws_iam_user_details_provider'

class AwsIamUserDetailsProviderTest < Minitest::Test
  Username = "test"
  def setup
    @mock_iam_resource = Minitest::Mock.new
    @mock_iam_resource_user = Minitest::Mock.new
  end

  def test_has_mfa_enabled_returns_true
    @mock_iam_resource_user.expect :mfa_devices, ['device']
    user_details_provider = AwsIam::UserDetailsProvider.new
    user_details_provider.user(@mock_iam_resource_user)
    assert user_details_provider.has_mfa_enabled?
  end

  def test_has_mfa_enabled_returns_false
    @mock_iam_resource_user.expect :mfa_devices, []
    user_details_provider = AwsIam::UserDetailsProvider.new
    user_details_provider.user(@mock_iam_resource_user)
    refute user_details_provider.has_mfa_enabled?
  end
  
  def test_has_console_password_returns_true
    mock_login_profile = Minitest::Mock.new
    mock_login_profile.expect :create_date, 'date'
    @mock_iam_resource_user.expect :login_profile, mock_login_profile
    user_details_provider = AwsIam::UserDetailsProvider.new
    user_details_provider.user(@mock_iam_resource_user)
    assert user_details_provider.has_console_password?
  end

  def test_has_console_password_returns_false
    mock_login_profile = Minitest::Mock.new
    mock_login_profile.expect :create_date, nil
    @mock_iam_resource_user.expect :login_profile, mock_login_profile
    user_details_provider = AwsIam::UserDetailsProvider.new
    user_details_provider.user(@mock_iam_resource_user)
    refute user_details_provider.has_console_password?
  end
  
  def test_has_console_password_returns_false_when_nosuchentity
    mock_login_profile = Minitest::Mock.new
    mock_login_profile.expect :create_date, nil do |args|
      raise Aws::IAM::Errors::NoSuchEntity.new(nil, nil)
    end
    @mock_iam_resource_user.expect :login_profile, mock_login_profile
    user_details_provider = AwsIam::UserDetailsProvider.new
    user_details_provider.user(@mock_iam_resource_user)
    refute user_details_provider.has_console_password?
  end
  
  def test_has_console_password_throws
    mock_login_profile = Minitest::Mock.new
    mock_login_profile.expect :create_date, nil do |args|
      raise ArgumentError
    end
    @mock_iam_resource_user.expect :login_profile, mock_login_profile
    user_details_provider = AwsIam::UserDetailsProvider.new
    user_details_provider.user(@mock_iam_resource_user)
    
    assert_raises ArgumentError do
      user_details_provider.has_console_password?
    end
  end

  def test_access_keys_returns_access_keys
    access_key = Object.new
    @mock_iam_resource_user.expect :access_keys, [access_key]
    user_details_provider = AwsIam::UserDetailsProvider.new
    user_details_provider.user(@mock_iam_resource_user)

    assert_equal [access_key], user_details_provider.access_keys
  end
end