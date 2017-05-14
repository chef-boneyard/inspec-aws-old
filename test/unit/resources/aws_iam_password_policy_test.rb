require 'helper'
require 'aws_iam_password_policy'
require 'aws-sdk'
require 'json'

class AwsIamPasswordPolicyTest < Minitest::Test
  def setup
    @mockConn = Minitest::Mock.new
    @mockResource = Minitest::Mock.new

    @mockConn.expect :iam_resource, @mockResource
  end

  def test_policy_exists_when_policy_exists
    @mockResource.expect :account_password_policy, true

    assert_equal true, AwsIamPasswordPolicy.new(@mockConn).exists?
  end

  def test_policy_does_not_exists_when_no_policy
    @mockResource.expect :account_password_policy, nil do |args|
      raise Aws::IAM::Errors::NoSuchEntity.new nil, nil
    end

    assert_equal false, AwsIamPasswordPolicy.new(@mockConn).exists?
  end

  def test_throws_when_password_age_0
    policyObject = Minitest::Mock.new
    policyObject.expect :expire_passwords, false

    @mockResource.expect :account_password_policy, policyObject

    e = assert_raises Exception do
      AwsIamPasswordPolicy.new(@mockConn).max_password_age
    end

    assert_equal e.message, 'this policy does not expire passwords'
  end

  def test_prevent_password_reuse_returns_true_when_not_nil
    @mockResource.expect :account_password_policy, create_mock_policy(password_reuse_prevention: Object.new)

    assert_equal true, AwsIamPasswordPolicy.new(@mockConn).prevent_password_reuse?
  end

  def test_prevent_password_reuse_returns_false_when_nil
    @mockResource.expect :account_password_policy, create_mock_policy(password_reuse_prevention: nil)

    assert_equal false, AwsIamPasswordPolicy.new(@mockConn).prevent_password_reuse?
  end

  def test_number_of_passwords_to_remember_throws_when_nil
    @mockResource.expect :account_password_policy, create_mock_policy(password_reuse_prevention: nil)

    e = assert_raises Exception do
      AwsIamPasswordPolicy.new(@mockConn).number_of_passwords_to_remember
    end

    assert_equal e.message, 'this policy does not prevent password reuse'
  end


  def test_number_of_passwords_to_remember_returns_configured_value
    expectedValue = 5
    @mockResource.expect :account_password_policy, create_mock_policy(password_reuse_prevention: expectedValue)

    assert_equal expectedValue, AwsIamPasswordPolicy.new(@mockConn).number_of_passwords_to_remember
  end

  private 

  def create_mock_policy(password_reuse_prevention: nil)
    Class.new {
      define_method(:password_reuse_prevention) { password_reuse_prevention }
    }.new
  end
end
