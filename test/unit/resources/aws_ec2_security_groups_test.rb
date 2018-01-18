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
#                            Filter Criteria
#=============================================================================#
class AwsESGFilterCriteria < Minitest::Test
  def setup
    AwsEc2SecurityGroups::BackendFactory.select(AwsMESGB::Basic)
  end
  
  def test_filter_vpc_id
    hit = AwsEc2SecurityGroups.new.where(vpc_id: 'vpc-12345678')
    assert(hit.exists?)

    miss = AwsEc2SecurityGroups.new.where(vpc_id: 'vpc-87654321')
    refute(miss.exists?)
  end

  def test_filter_group_name
    hit = AwsEc2SecurityGroups.new.where(group_name: 'alpha')
    assert(hit.exists?)

    miss = AwsEc2SecurityGroups.new.where(group_name: 'nonesuch')
    refute(miss.exists?)
  end

end

#=============================================================================#
#                            Properties
#=============================================================================#
class AwsESGProperties < Minitest::Test
  def setup
    AwsEc2SecurityGroups::BackendFactory.select(AwsMESGB::Basic)
  end
  
  def test_property_group_ids
    basic = AwsEc2SecurityGroups.new
    assert_kind_of(Array, basic.group_ids)
    assert(basic.group_ids.include?('sg-aaaabbbb'))
    refute(basic.group_ids.include?(nil))
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

  class Basic < AwsEc2SecurityGroups::Backend
    def describe_security_groups(query)
      fixtures = [
        OpenStruct.new({
          group_id: 'sg-aaaabbbb',
          group_name: 'alpha',
          vpc_id: 'vpc-aaaabbbb',
        }),
        OpenStruct.new({
          group_id: 'sg-12345678',
          group_name: 'beta',
          vpc_id: 'vpc-12345678',
        }),
      ]

      selected = fixtures.select do |sg|
        query.keys.all? do |criterion|
          query[criterion] == sg[criterion]
        end
      end

      OpenStruct.new({ security_groups: selected })
    end
  end

end
