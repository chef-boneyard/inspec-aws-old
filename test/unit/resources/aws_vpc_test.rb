require 'helper'
require 'aws_vpc'

# MAVSB = MockAwsVpcSingularBackend
# Abbreviation not used outside this file

#=============================================================================#
#                            Constructor Tests
#=============================================================================#
class AwsVpcConstructorTest < Minitest::Test

  def setup
    AwsVpc::BackendFactory.select(MAVSB::Empty)
  end

  def test_empty_params_ok
    AwsVpc.new
  end

  def test_accepts_vpc_id_as_scalar
    AwsVpc.new('vpc-12345678')
  end

  def test_accepts_vpc_id_as_hash
    AwsVpc.new(vpc_id: 'vpc-1234abcd')
  end

  def test_rejects_unrecognized_params
    assert_raises(ArgumentError) { AwsVpc.new(shoe_size: 9) }
  end

  def test_rejects_invalid_vpc_id
    assert_raises(ArgumentError) { AwsVpc.new('vpc-rofl') }
  end
end

#=============================================================================#
#                               Test Fixtures
#=============================================================================#

module MAVSB
  class Empty < AwsVpc::Backend
    def describe_vpcs(query)
      OpenStruct.new(vpcs: [])
    end
  end
end