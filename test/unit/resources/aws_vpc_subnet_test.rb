# encoding: utf-8
require 'ostruct'
require 'helper'
require 'aws_vpc_subnet'

# MVSSB = MockVpcSubnetSingleBackend
# Abbreviation not used outside this file

#=============================================================================#
#                            Constructor Tests
#=============================================================================#
class AwsVpcSubnetConstructorTest < Minitest::Test
  def setup
    AwsVpcSubnet::BackendFactory.select(AwsMVSSB::Basic)
  end

  def test_constructor_no_args_raises
    assert_raises(ArgumentError) { AwsVpcSubnet.new }
  end

  def test_constructor_expected_well_formed_args
    AwsVpcSubnet.new(vpc_id: 'vpc-a01106c2')
  end

  def test_constructor_reject_unknown_resource_params
    assert_raises(ArgumentError) { AwsVpcSubnet.new(bla: 'blabla') }
  end
end

#=============================================================================#
#                               Recall
#=============================================================================#

class AwsVpcSubnetRecallTest < Minitest::Test
  def setup
    AwsVpcSubnet::BackendFactory.select(AwsMVSSB::Basic)
  end

  def test_searching
    assert_equal(true, AwsVpcSubnet.new(vpc_id: 'vpc-a01106c2').exists?)
    assert_equal(false, AwsVpcSubnet.new(vpc_id: 'NonExistentVPC').exists?)
  end
end


#=============================================================================#
#                               Test Fixtures
#=============================================================================#

module AwsMVSSB
  class Basic < AwsVpcSubnet::Backend
    def describe_subnets(query)
      subnets = OpenStruct.new({
        :subnets => [
          OpenStruct.new({
            availability_zone: "us-east-1",
            available_ip_address_count: 251,
            cidr_block: "10.0.1.0/24",
            default_for_az: false,
            map_public_ip_on_launch: false,
            state: "available",
            subnet_id: "subnet-9d4a7b6c",
            vpc_id: "vpc-a01106c2",
          }),
        ]
      })
    end
  end
end
