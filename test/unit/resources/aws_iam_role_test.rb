require 'helper'
require 'aws_iam_role'

# MIRB = MockIamRoleBackend
# Abbreviation not used outside this file

#=============================================================================#
#                            Constructor Tests
#=============================================================================#
class AwsIamRoleConstructorTest < Minitest::Test
  def setup
    AwsIamRole::BackendFactory.select(AwsMIRB::Basic)
  end

  def test_constructor_some_args_required
    assert_raises(ArgumentError) { AwsIamRole.new }
  end

  def test_constructor_accepts_scalar_role_name
    AwsIamRole.new('alpha')
  end

  def test_constructor_accepts_role_name_as_hash
    AwsIamRole.new(role_name: 'alpha')    
  end
  
  def test_constructor_rejects_unrecognized_resource_params
    assert_raises(ArgumentError) { AwsIamRole.new(beep: 'boop') }
  end
end

#=============================================================================#
#                               Test Fixtures
#=============================================================================#
module AwsMIRB
  class Miss
    def get_role(query)
      raise Aws::IAM::Errors::NoSuchEntity.new('Nope', 'Nope')
    end
  end

  class Basic
    def get_role(query)
      fixtures = {
        alpha => OpenStruct.new({
          role_name: 'alpha',
        }),
      }
      unless fixtures.key?(query[:role_name])
        raise Aws::IAM::Errors::NoSuchEntity.new('Nope', 'Nope')
      end
      OpenStruct.new({
        role => fixtures[query[:role_name]]
      })
    end
  end
end