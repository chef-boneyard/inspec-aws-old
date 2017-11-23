# author: Simon Varlow
require 'helper'
require 'aws_iam_user'

<<<<<<< HEAD
# rubocop:disable Metrics/ClassLength
class AwsIamUserTest < Minitest::Test
  Username = 'test'.freeze
=======
# MAUIB = MockAwsIamUserBackend
# Abbreviation not used outside this file

#=============================================================================#
#                            Constructor Tests
#=============================================================================#
class AwsIamUserConstructorTest < Minitest::Test
>>>>>>> Add constructor tests

  def setup
    AwsIamUser::BackendFactory.select(MAIUB::JustBob)
  end

<<<<<<< HEAD
  def test_that_exists_returns_true_if_user_exists
    @mock_user_provider.expect :user, @mock_user, [Username]
    @mock_dets_provider.expect :exists?, true
    @mock_dets_prov_ini.expect :create, @mock_dets_provider, [@mock_user]
    assert AwsIamUser.new(
      @mock_user,
      @mock_user_provider,
      @mock_dets_prov_ini,
    ).exists?
  end

  def test_that_exists_returns_false_if_user_does_not_exist
    @mock_user_provider.expect :user, @mock_user, [Username]
    @mock_dets_provider.expect :exists?, false
    @mock_dets_prov_ini.expect :create, @mock_dets_provider, [@mock_user]
    refute AwsIamUser.new(
      @mock_user,
      @mock_user_provider,
      @mock_dets_prov_ini,
    ).exists?
  end

  def test_that_mfa_enable_returns_true_if_mfa_enabled
    @mock_user_provider.expect :user, @mock_user, [Username]
    @mock_dets_provider.expect :has_mfa_enabled?, true
    @mock_dets_prov_ini.expect :create, @mock_dets_provider, [@mock_user]
    assert AwsIamUser.new(
      @mock_user,
      @mock_user_provider,
      @mock_dets_prov_ini,
    ).has_mfa_enabled?
=======
  def test_empty_params_throws_exception
    assert_raises(ArgumentError) { AwsIamUser.new }
>>>>>>> Add constructor tests
  end

  def test_accepts_username_as_scalar
    AwsIamUser.new('bob')
  end

  def test_accepts_username_as_hash
    AwsIamUser.new(username: 'bob')
  end

  def test_rejects_unrecognized_params
    assert_raises(ArgumentError) { AwsIamUser.new(shoe_size: 9) }
  end
end

#=============================================================================#
#                               Search / Recall
#=============================================================================#
class AwsIamUserRecallTest < Minitest::Test
  def setup
    AwsIamUser::BackendFactory.select(MAIUB::JustBob)
  end

  def test_search_miss_is_not_an_exception
    user = AwsIamUser.new('tommy')
    refute user.exists?
  end

  def test_search_hit_via_scalar_works
    user = AwsIamUser.new('bob')
    assert user.exists?
    assert_equal('bob', user.username)
  end

  def test_search_hit_via_hash_works
    user = AwsIamUser.new(username: 'bob')
    assert user.exists?
    assert_equal('bob', user.username)    
  end
end

  # def test_that_mfa_enable_returns_true_if_mfa_enabled
  #   @mock_user_provider.expect :user, @mock_user, [Username]
  #   @mock_dets_provider.expect :has_mfa_enabled?, true
  #   @mock_dets_prov_ini.expect :create, @mock_dets_provider, [@mock_user]
  #   assert AwsIamUser.new(
  #     @mock_user,
  #     @mock_user_provider,
  #     @mock_dets_prov_ini,
  #   ).has_mfa_enabled?
  # end

  # def test_that_mfa_enable_returns_false_if_mfa_is_not_enabled
  #   @mock_user_provider.expect :user, @mock_user, [Username]
  #   @mock_dets_provider.expect :has_mfa_enabled?, false
  #   @mock_dets_prov_ini.expect :create, @mock_dets_provider, [@mock_user]
  #   refute AwsIamUser.new(
  #     @mock_user,
  #     @mock_user_provider,
  #     @mock_dets_prov_ini,
  #   ).has_mfa_enabled?
  # end

  # def test_that_console_password_returns_true_if_console_password_set
  #   @mock_user_provider.expect :user, @mock_user, [Username]
  #   @mock_dets_provider.expect :has_console_password?, true
  #   @mock_dets_prov_ini.expect :create, @mock_dets_provider, [@mock_user]
  #   assert AwsIamUser.new(
  #     @mock_user,
  #     @mock_user_provider,
  #     @mock_dets_prov_ini,
  #   ).has_console_password?
  # end

  # def test_that_console_password_returns_false_if_console_password_not_set
  #   @mock_user_provider.expect :user, @mock_user, [Username]
  #   @mock_dets_provider.expect :has_console_password?, false
  #   @mock_dets_prov_ini.expect :create, @mock_dets_provider, [@mock_user]
  #   refute AwsIamUser.new(
  #     @mock_user,
  #     @mock_user_provider,
  #     @mock_dets_prov_ini,
  #   ).has_console_password?
  # end

  # def test_that_access_keys_returns_aws_iam_access_key_resources
  #   stub_aws_access_key = Object.new
  #   stub_access_key_resource = Object.new
  #   mock_access_key_factory = Minitest::Mock.new

  #   @mock_user_provider.expect :user, @mock_user, [Username]
  #   @mock_dets_provider.expect :access_keys, [stub_aws_access_key]
  #   @mock_dets_prov_ini.expect :create, @mock_dets_provider, [@mock_user]
  #   mock_access_key_factory.expect(
  #     :create_access_key,
  #     stub_access_key_resource,
  #     [stub_aws_access_key],
  #   )

  #   assert_equal(
  #     stub_access_key_resource,
  #     AwsIamUser.new(
  #       @mock_user,
  #       @mock_user_provider,
  #       @mock_dets_prov_ini,
  #       mock_access_key_factory,
  #     ).access_keys[0],
  #   )

  #   mock_access_key_factory.verify
  # end

  # def test_to_s
  #   test_user = { name: Username, has_mfa_enabled?: true }
  #   @mock_user_provider.expect :user, test_user, [Username]
  #   @mock_dets_provider.expect :name, Username
  #   @mock_dets_prov_ini.expect :create, @mock_dets_provider, [test_user]
  #   expected = "IAM User #{Username}"
  #   test = AwsIamUser.new(
  #     { name: Username },
  #     @mock_user_provider,
  #     @mock_dets_prov_ini,
  #   ).to_s
  #   assert_equal expected, test
  # end

#=============================================================================#
#                               Test Fixtures
#=============================================================================#

module MAIUB
  class JustBob < AwsIamUser::Backend
    def get_user(criteria)
      raise Aws::IAM::Errors::NoSuchEntityException.new(nil, nil) unless criteria[:username] == 'bob'
      OpenStruct.new({
        user: OpenStruct.new({
          arn: "arn:aws:iam::123456789012:user/bob", 
          create_date: Time.parse("2012-09-21T23:03:13Z"), 
          path: "/", 
          user_id: "AKIAIOSFODNN7EXAMPLE", 
          user_name: "bob", 
        }), 
      })
    end
  end
end