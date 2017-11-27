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
    AwsIamUser::BackendFactory.select(MAIUB::Three)
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
    AwsIamUser.new('erin')
  end

  def test_accepts_username_as_hash
    AwsIamUser.new(username: 'erin')
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
    AwsIamUser::BackendFactory.select(MAIUB::Three)
  end

  def test_search_miss_is_not_an_exception
    user = AwsIamUser.new('tommy')
    refute user.exists?
  end

  def test_search_hit_via_scalar_works
    user = AwsIamUser.new('erin')
    assert user.exists?
    assert_equal('erin', user.username)
  end

  def test_search_hit_via_hash_works
    user = AwsIamUser.new(username: 'erin')
    assert user.exists?
    assert_equal('erin', user.username)    
  end
end

#=============================================================================#
#                                Properties
#=============================================================================#

class AwsIamUserPropertiesTest < Minitest::Test
  def setup
    AwsIamUser::BackendFactory.select(MAIUB::Three)
  end

  #-----------------------------------------------------#
  # username property
  #-----------------------------------------------------#
  def test_property_username_correct_on_hit
    user = AwsIamUser.new(username: 'erin')
    assert_equal('erin', user.username)
  end

  #-----------------------------------------------------#
  # has_console_password property and predicate
  #-----------------------------------------------------#
  def test_property_password_positive
    user = AwsIamUser.new(username: 'erin')
    assert_equal(true, user.has_console_password)
    assert_equal(true, user.has_console_password?)
  end

  def test_property_password_negative
    user = AwsIamUser.new(username: 'leslie')
    assert_equal(false, user.has_console_password)
    assert_equal(false, user.has_console_password?)
  end

  #-----------------------------------------------------#
  # has_mfa_enabled property and predicate
  #-----------------------------------------------------#
  def test_property_mfa_positive
    user = AwsIamUser.new(username: 'erin')
    assert_equal(true, user.has_mfa_enabled)
    assert_equal(true, user.has_mfa_enabled?)
  end

  def test_property_mfa_negative
    user = AwsIamUser.new(username: 'leslie')
    assert_equal(false, user.has_mfa_enabled)
    assert_equal(false, user.has_mfa_enabled?)
  end
  
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
end

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
  class Three < AwsIamUser::Backend
    def get_user(criteria)
      people = {
        'erin' => OpenStruct.new({
          user: OpenStruct.new({
            arn: "arn:aws:iam::123456789012:user/erin", 
            create_date: Time.parse("2016-09-21T23:03:13Z"), 
            path: "/", 
            user_id: "AKIAIOSFODNN7EXAERIN", 
            user_name: "erin", 
          }),
        }),
        'leslie' => OpenStruct.new({
          user: OpenStruct.new({
            arn: "arn:aws:iam::123456789012:user/leslie", 
            create_date: Time.parse("2017-09-21T23:03:13Z"), 
            path: "/", 
            user_id: "AKIAIOSFODNN7EXAERIN", 
            user_name: "leslie", 
          }),
        }),
        'jared' => OpenStruct.new({
          user: OpenStruct.new({
            arn: "arn:aws:iam::123456789012:user/jared", 
            create_date: Time.parse("2017-09-21T23:03:13Z"), 
            path: "/", 
            user_id: "AKIAIOSFODNN7EXAERIN", 
            user_name: "jared", 
          }),
        }),
      }
      raise Aws::IAM::Errors::NoSuchEntityException.new(nil, nil) unless people.key?(criteria[:user_name])
      people[criteria[:user_name]]
    end

    def get_login_profile(criteria)
      # Leslie has no password
      # Jared's is expired
      people = {
        'erin' => OpenStruct.new({
          login_profile: OpenStruct.new({
            user_name: 'erin',
            password_reset_required: false,
            create_date: Time.parse("2016-09-21T23:03:13Z"),
          }),
        }),
        'jared' => OpenStruct.new({
          login_profile: OpenStruct.new({
            user_name: 'jared',
            password_reset_required: true,
            create_date: Time.parse("2017-09-21T23:03:13Z"),
          }),
        }),
      }
      raise Aws::IAM::Errors::NoSuchEntityException.new(nil, nil) unless people.key?(criteria[:user_name])
      people[criteria[:user_name]]
    end
  end
end