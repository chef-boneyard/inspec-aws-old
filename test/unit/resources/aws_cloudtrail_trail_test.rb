require 'ostruct'
require 'helper'
require 'aws_cloudtrail_trail'

# MCTTB = MockCloudTrailTrailBackend
# Abbreviation not used outside this file

#=============================================================================#
#                            Constructor Tests
#=============================================================================#
class AwsCloudTrailTrailConstructorTest < Minitest::Test
  def setup
    AwsCloudTrailTrail::BackendFactory.select(AwsMCTTB::NoTrails)
  end

  def test_constructor_no_args_ok
    trail = AwsCloudTrailTrail.new
    assert_equal('Default', trail.trail_name)
  end

  def test_constructor_accepts_scalar_name
    trail = AwsCloudTrailTrail.new('nonesuch')
    assert_equal('nonesuch', trail.trail_name)    
  end

  def test_constructor_accepts_name_as_hash
    trail = AwsCloudTrailTrail.new(trail_name: 'norsuch')
    assert_equal('norsuch', trail.trail_name)
  end
  
  def test_constructor_rejects_unrecognized_resource_params
    assert_raises(ArgumentError) { AwsCloudTrailTrail.new(beep: 'boop') }
  end
end

#=============================================================================#
#                               Search / Recall
#=============================================================================#
class AwsCloudTrailTrailRecallTest < Minitest::Test

  def test_recall_default_when_default_exists
    AwsCloudTrailTrail::BackendFactory.select(AwsMCTTB::DefaultOnly)
    assert(AwsCloudTrailTrail.new.exists?)
  end

  def test_recall_default_when_default_absent
    AwsCloudTrailTrail::BackendFactory.select(AwsMCTTB::TwoTrails)
    refute(AwsCloudTrailTrail.new.exists?)
  end

  def test_recall_custom_when_multiple_exist
    AwsCloudTrailTrail::BackendFactory.select(AwsMCTTB::TwoTrails)
    assert(AwsCloudTrailTrail.new('applications').exists?)
  end
end

#=============================================================================#
#                                Properties
#=============================================================================#

#-------------------------------  kms_key_id ---------------------------------#
class AwsCloudTrailTrailKmsKeyIdPropertyTest < Minitest::Test
  def setup
    AwsCloudTrailTrail::BackendFactory.select(AwsMCTTB::TwoTrails)
  end

  def test_kms_key_id_property_when_present
    trail = AwsCloudTrailTrail.new('security')
    assert_equal('3a86879e-dead-beef-acbc-56db6b873c88', trail.kms_key_id)
  end

  def test_kms_key_id_property_when_absent
    assert_nil(AwsCloudTrailTrail.new('applications').kms_key_id)
  end
end

#----------------------------  log_group_name ---------------------------------#
class AwsCloudTrailTrailLogGroupNamePropertyTest < Minitest::Test
  def setup
    AwsCloudTrailTrail::BackendFactory.select(AwsMCTTB::TwoTrails)
  end

  def test_log_group_name_property_when_present
    trail = AwsCloudTrailTrail.new('security')
    assert_equal('security-logs', trail.log_group_name)
  end

  def test_log_group_name_property_when_absent
    assert_nil(AwsCloudTrailTrail.new('applications').log_group_name)
  end
end

#-----------------------------  s3_bucket_name ---------------------------------#
class AwsCloudTrailTrailS3BucketNamePropertyTest < Minitest::Test
  def test_s3_bucket_name_property_when_present
    AwsCloudTrailTrail::BackendFactory.select(AwsMCTTB::TwoTrails)    
    trail = AwsCloudTrailTrail.new('security')
    assert_equal('security-bucket', trail.s3_bucket_name)
  end
end

#=============================================================================#
#                              Custom Matchers
#=============================================================================#

#------------------------------- multi_region --------------------------------#
class AwsCloudTrailTrailMultiRegionMatcherTest < Minitest::Test
  def setup
    AwsCloudTrailTrail::BackendFactory.select(AwsMCTTB::TwoTrails)
  end

  def test_multi_region_matcher_methods
    trail = AwsCloudTrailTrail.new
    assert_respond_to(trail, :is_multi_region)
    assert_respond_to(trail, :be_multi_region?)
  end

  def test_multi_region_when_true
    trail = AwsCloudTrailTrail.new('security')
    assert(trail.is_multi_region)
    assert(trail.be_multi_region?)
  end

  def test_multi_region_when_false
    trail = AwsCloudTrailTrail.new('applications')
    refute(trail.is_multi_region)
    refute(trail.be_multi_region?)
  end
end

#------------------------------- encrypted ---------------------------------#
class AwsCloudTrailTrailEncryptedMatcherTest < Minitest::Test
  def setup
    AwsCloudTrailTrail::BackendFactory.select(AwsMCTTB::TwoTrails)
  end

  def test_encrypted_matcher_methods
    trail = AwsCloudTrailTrail.new
    assert_respond_to(trail, :is_encrypted)
    assert_respond_to(trail, :be_encrypted?)
  end

  def test_encrypted_when_true
    trail = AwsCloudTrailTrail.new('security')
    assert(trail.is_encrypted)
    assert(trail.be_encrypted?)
  end

  def test_encrypted_when_false
    trail = AwsCloudTrailTrail.new('applications')
    refute(trail.is_encrypted)
    refute(trail.be_encrypted?)
  end
end

#------------------------- log_file_validation_enabled -----------------------------#
class AwsCloudTrailTrailLogFileValidationMatcherTest < Minitest::Test
  def setup
    AwsCloudTrailTrail::BackendFactory.select(AwsMCTTB::TwoTrails)
  end

  def test_log_file_validation_enabled_matcher_methods
    trail = AwsCloudTrailTrail.new
    assert_respond_to(trail, :is_log_file_validation_enabled)
    assert_respond_to(trail, :has_log_file_validation_enabled?)
  end

  def test_log_file_validation_enabled_when_true
    trail = AwsCloudTrailTrail.new('security')
    assert(trail.is_log_file_validation_enabled)
    assert(trail.has_log_file_validation_enabled?)
  end

  def test_log_file_validation_enabled_when_false
    trail = AwsCloudTrailTrail.new('applications')
    refute(trail.is_log_file_validation_enabled)
    refute(trail.has_log_file_validation_enabled?)
  end
end

#=============================================================================#
#                               Test Fixtures
#=============================================================================#

module AwsMCTTB
  def filter_trails(data, query)
    matched_trails = data.trail_list.select do |trail|
      query[:trail_name_list].any? {|name| trail.name == name }
    end
    OpenStruct.new(trail_list: matched_trails)
  end
  module_function :filter_trails

  class NoTrails < AwsCloudTrailTrail::Backend
    def describe_trails(query)
      data = OpenStruct.new({
        trail_list: []
      })
      AwsMCTTB::filter_trails(data, query)
    end
  end

  class DefaultOnly < AwsCloudTrailTrail::Backend
    def describe_trails(query)
      data = OpenStruct.new({
        trail_list: [
          OpenStruct.new({
            name: 'Default',
          }),
        ]
      })
      AwsMCTTB::filter_trails(data, query)
    end
  end

  class TwoTrails < AwsCloudTrailTrail::Backend
    def describe_trails(query)
      data = OpenStruct.new({
        trail_list: [
          OpenStruct.new({
            name: 'security',
            kms_key_id: '3a86879e-dead-beef-acbc-56db6b873c88',
            log_group_name: 'security-logs',
            s3_bucket_name: 'security-bucket',
            log_file_validation_enabled: true,
            is_multi_region_trail: true,
          }),
          OpenStruct.new({
            name: 'applications',
            log_file_validation_enabled: false,
            is_multi_region_trail: false,
          }),
        ]
      })
      AwsMCTTB::filter_trails(data, query)
    end
  end
end