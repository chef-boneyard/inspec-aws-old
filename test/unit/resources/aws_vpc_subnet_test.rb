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

  def test_constructor_no_vpc_id
    AwsVpcSubnet.new(subnet_id: 'subnet-9d4a7b6c')
  end

  def test_constructor_no_subnet_id
    AwsVpcSubnet.new(vpc_id: 'vpc-a01106c2')
  end

  def test_constructor_expected_well_formed_args
    AwsVpcSubnet.new(vpc_id: 'vpc-a01106c2', subnet_id: 'subnet-9d4a7b6c')
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
    assert_equal(false, AwsVpcSubnet.new(vpc_id: 'vpc-00000000').exists?)
  end
end

#=============================================================================#
#                               properties
#=============================================================================#

class AwsVpcSubnetPropertiesTest < Minitest::Test
  def setup
    AwsVpcSubnet::BackendFactory.select(AwsMVSSB::Basic)
  end

  def test_property_subnet_id
    assert_equal('subnet-9d4a7b6c', AwsVpcSubnet.new(vpc_id: 'vpc-a01106c2', subnet_id: 'subnet-9d4a7b6c').subnet_id)
  end

  def test_property_vpc_id
    assert_equal('vpc-a01106c2', AwsVpcSubnet.new(vpc_id: 'vpc-a01106c2', subnet_id: 'subnet-9d4a7b6c').vpc_id)
  end

  def test_property_cidr_block
    assert_equal('10.0.1.0/24', AwsVpcSubnet.new(vpc_id: 'vpc-a01106c2', subnet_id: 'subnet-9d4a7b6c').cidr_block)
  end
end


#=============================================================================#
#                               Test Fixtures
#=============================================================================#

module AwsMVSSB
  class Basic < AwsVpcSubnet::Backend
    def describe_subnets(query)
      subnets = {
        'vpc-a01106c2' => OpenStruct.new({
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
        }),
        'empty' => OpenStruct.new({
          :subnets => []
        })
      }
      return subnets[query[:filters][0][:values][0]] unless subnets[query[:filters][0][:values][0]].nil?
      subnets['empty']
    end
  end
end
