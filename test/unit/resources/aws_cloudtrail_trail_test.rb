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

#=============================================================================#
#                                Properties
#=============================================================================#

#=============================================================================#
#                               Test Fixtures
#=============================================================================#

module AwsMCTTB
  class NoTrails < AwsCloudTrailTrail::Backend
    def describe_trails(query)
      OpenStruct.new({
        trails: []
      })
    end
  end
end