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
          }),
          OpenStruct.new({
            name: 'applications',
          }),
        ]
      })
      AwsMCTTB::filter_trails(data, query)
    end
  end
end