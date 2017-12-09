require 'ostruct'
require 'helper'
require 'aws_ec2_security_groups'

# MESGB = MockEc2SecurityGroupBackend
# Abbreviation not used outside this file

#=============================================================================#
#                            Constructor Tests
#=============================================================================#
class AwsESGConstructor < Minitest::Test
  def setup
    AwsEc2SecurityGroups::BackendFactory.select(AwsMESGB::Empty)
  end
  
  def test_constructor_no_args_ok
    AwsEc2SecurityGroups.new
  end

  def test_constructor_reject_unknown_resource_params
    assert_raises(ArgumentError) { AwsEc2SecurityGroups.new(beep: 'boop') }
  end
end

#=============================================================================#
#                               Test Fixtures
#=============================================================================#

module AwsMESGB
  class Empty < AwsEc2SecurityGroups::Backend
    def describe_security_groups(_query)
      OpenStruct.new({
        security_groups: [],
      })
    end
  end
end
