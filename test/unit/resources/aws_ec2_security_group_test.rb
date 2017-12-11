require 'ostruct'
require 'helper'
require 'aws_ec2_security_group'

# MESGSB = MockEc2SecurityGroupSingleBackend
# Abbreviation not used outside this file

#=============================================================================#
#                            Constructor Tests
#=============================================================================#
class AwsESGSConstructor < Minitest::Test
  def setup
    AwsEc2SecurityGroup::BackendFactory.select(AwsMESGSB::Empty)
  end
  
  def test_constructor_no_args_raises
    assert_raises(ArgumentError) { AwsEc2SecurityGroup.new }
  end

  def test_constructor_accept_scalar_param
    AwsEc2SecurityGroup.new('sg-12345678')
  end

  def test_constructor_expected_well_formed_args
    {
      id: 'sg-1234abcd',
      group_id: 'sg-1234abcd',
      vpc_id: 'vpc-1234abcd',
      group_name: 'some-group',
    }.each do |param, value| 
      AwsEc2SecurityGroup.new(param => value)
    end
  end

  def test_constructor_reject_malformed_args
    {
      id: 'sg-xyz-123',
      group_id: '1234abcd',
      vpc_id: 'vpc_1234abcd',
    }.each do |param, value| 
      assert_raises(ArgumentError) { AwsEc2SecurityGroup.new(param => value) }
    end
  end

  def test_constructor_reject_unknown_resource_params
    assert_raises(ArgumentError) { AwsEc2SecurityGroup.new(beep: 'boop') }
  end
end

#=============================================================================#
#                               Test Fixtures
#=============================================================================#

module AwsMESGSB
  class Empty < AwsEc2SecurityGroup::Backend
    def describe_security_groups(_query)
      OpenStruct.new({
        security_groups: [],
      })
    end
  end
end
