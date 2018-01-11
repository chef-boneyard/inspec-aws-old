require 'ostruct'
require 'helper'
require 'aws_rds_instance'

# MRDSIB = MockRDSInstanceBackend
# Abbreviation not used outside this file

#=============================================================================#
#                            Constructor Tests
#=============================================================================#
class AwsMDBIConstructor < Minitest::Test
  def setup
    AwsRdsInstance::BackendFactory.select(AwsMRDSIB::Empty)
  end
  
  def test_constructor_no_args_raises
    assert_raises(ArgumentError) { AwsRdsInstance.new }
  end

  def test_constructor_accept_scalar_param
    AwsRdsInstance.new('test-instance-id')
  end

  def test_constructor_expected_well_formed_args
    {
      db_id: 'test-instance-id',
    }.each do |param, value| 
      AwsRdsInstance.new(param => value)
    end
  end

  def test_constructor_reject_malformed_args
    {
      db_id: 'no_good',
    }.each do |param, value|
      assert_raises(ArgumentError) { AwsRdsInstance.new(param => value) }
    end
  end

  def test_constructor_reject_unknown_resource_params
    assert_raises(ArgumentError) { AwsRdsInstance.new(beep: 'boop') }
  end
end

#=============================================================================#
#                               Properties
#=============================================================================#

#=============================================================================#
#                               Test Fixtures
#=============================================================================#

module AwsMRDSIB
  class Empty < AwsRdsInstance::Backend
    def describe_db_instances(_query)
      OpenStruct.new({
                         db_instances: [],
                     })
    end
  end

  class Basic < AwsRdsInstance::Backend
    def describe_db_instances(query)
      fixtures = [
          OpenStruct.new({
                             db_id: 'some-db',
                         }),
          OpenStruct.new({
                             db_id: 'awesome-db',
                         }),
      ]

      selected = fixtures.select do |db|
        query[:filters].all? do |filter|
          filter[:values].include?(db[filter[:name].tr('_','-')])
        end
      end

      OpenStruct.new({ db_instances: selected })
    end
  end

end
