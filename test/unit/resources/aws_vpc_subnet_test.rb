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
    AwsVpcSubnet.new(subnet_id: 'subnet-12345678')
  end

  def test_constructor_no_subnet_id
    AwsVpcSubnet.new(vpc_id: 'vpc-12345678')
  end

  def test_constructor_expected_well_formed_args
    AwsVpcSubnet.new(vpc_id: 'vpc-12345678', subnet_id: 'subnet-12345678')
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

  def test_search_hit_via_hash_with_vpc_id_and_subnet_id_works
    assert AwsVpcSubnet.new(vpc_id: 'vpc-12345678', subnet_id: 'subnet-12345678').exists?
  end

  def test_search_miss_is_not_an_exception
    refute AwsVpcSubnet.new(vpc_id: 'vpc-00000000').exists?
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
    assert_equal('subnet-12345678', AwsVpcSubnet.new(vpc_id: 'vpc-12345678', subnet_id: 'subnet-12345678').subnet_id)
  end

  def test_property_vpc_id
    assert_equal('vpc-12345678', AwsVpcSubnet.new(vpc_id: 'vpc-12345678', subnet_id: 'subnet-12345678').vpc_id)
  end

  def test_property_cidr_block
    assert_equal('10.0.1.0/24', AwsVpcSubnet.new(vpc_id: 'vpc-12345678', subnet_id: 'subnet-12345678').cidr_block)
    assert_nil(AwsVpcSubnet.new(vpc_id: 'vpc-00000000', subnet_id: 'subnet-00000000').cidr_block)
  end

  def test_property_availability_zone
    assert_equal('us-east-1', AwsVpcSubnet.new(vpc_id: 'vpc-12345678', subnet_id: 'subnet-12345678').availability_zone)
    assert_nil(AwsVpcSubnet.new(vpc_id: 'vpc-00000000', subnet_id: 'subnet-00000000').availability_zone)
  end

  def test_property_available_ip_address_count
    assert_equal(251, AwsVpcSubnet.new(vpc_id: 'vpc-12345678', subnet_id: 'subnet-12345678').available_ip_address_count)
    assert_nil(AwsVpcSubnet.new(vpc_id: 'vpc-00000000', subnet_id: 'subnet-00000000').available_ip_address_count)
  end

  def test_property_default_for_az
    assert_equal(false, AwsVpcSubnet.new(vpc_id: 'vpc-12345678', subnet_id: 'subnet-12345678').default_for_az)
    assert_nil(AwsVpcSubnet.new(vpc_id: 'vpc-00000000', subnet_id: 'subnet-00000000').default_for_az)
  end

  def test_property_map_public_ip_on_launch
    assert_equal(false, AwsVpcSubnet.new(vpc_id: 'vpc-12345678', subnet_id: 'subnet-12345678').map_public_ip_on_launch)
    assert_nil(AwsVpcSubnet.new(vpc_id: 'vpc-00000000', subnet_id: 'subnet-00000000').map_public_ip_on_launch)
  end

  def test_property_state
    assert_equal('available', AwsVpcSubnet.new(vpc_id: 'vpc-12345678', subnet_id: 'subnet-12345678').state)
    assert_nil(AwsVpcSubnet.new(vpc_id: 'vpc-00000000', subnet_id: 'subnet-00000000').state)
  end

  def test_property_ipv_6_cidr_block_association_set
    assert_equal([], AwsVpcSubnet.new(vpc_id: 'vpc-12345678', subnet_id: 'subnet-12345678').ipv_6_cidr_block_association_set)
    assert_nil(AwsVpcSubnet.new(vpc_id: 'vpc-00000000', subnet_id: 'subnet-00000000').ipv_6_cidr_block_association_set)
  end

  def test_property_assign_ipv_6_address_on_creation
    assert_equal(false, AwsVpcSubnet.new(vpc_id: 'vpc-12345678', subnet_id: 'subnet-12345678').assign_ipv_6_address_on_creation)
    assert_nil(AwsVpcSubnet.new(vpc_id: 'vpc-00000000', subnet_id: 'subnet-00000000').assign_ipv_6_address_on_creation)
  end
end


#=============================================================================#
#                               Test Fixtures
#=============================================================================#

module AwsMVSSB
  class Basic < AwsVpcSubnet::Backend
    def describe_subnets(query)
      subnets = {
        'vpc-12345678' => OpenStruct.new({
          :subnets => [
            OpenStruct.new({
              availability_zone: "us-east-1",
              available_ip_address_count: 251,
              cidr_block: "10.0.1.0/24",
              default_for_az: false,
              map_public_ip_on_launch: false,
              state: "available",
              subnet_id: "subnet-12345678",
              vpc_id: "vpc-12345678",
              ipv_6_cidr_block_association_set: [],
              assign_ipv_6_address_on_creation: false,
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
