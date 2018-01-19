require 'helper'
require 'aws_iam_policys'

# MAIPPB = MockAwsIamPolicysPluralBackend
# Abbreviation not used outside this file

#=============================================================================#
#                            Constructor Tests
#=============================================================================#
class AwsIamPolicysConstructorTest < Minitest::Test

  def setup
    AwsIamPolicys::BackendFactory.select(MAIPPB::Empty)
  end

  def test_empty_params_ok
    AwsIamPolicys.new
  end

  def test_rejects_unrecognized_params
    assert_raises(ArgumentError) { AwsIamPolicys.new(shoe_size: 9) }
  end
end


#=============================================================================#
#                               Search / Recall
#=============================================================================#
class AwsIamPolicysRecallEmptyTest < Minitest::Test

  def setup
    AwsIamPolicys::BackendFactory.select(MAIPPB::Empty)
  end

  def test_search_miss_policy_empty_policy_list
    refute AwsIamPolicys.new.exists?
  end
end

class AwsIamPolicysRecallBasicTest < Minitest::Test

  def setup
    AwsIamPolicys::BackendFactory.select(MAIPPB::Basic)
  end

  def test_search_hit_via_empty_filter
    assert AwsIamPolicys.new.exists?
  end
end

#=============================================================================#
#                            Properties
#=============================================================================#
class AwsIamPolicysProperties < Minitest::Test
  def setup
    AwsIamPolicys::BackendFactory.select(MAIPPB::Basic)
  end
  
  def test_property_policy_names
    basic = AwsIamPolicys.new
    assert_kind_of(Array, basic.policy_names)
    assert(basic.policy_names.include?('test-policy-1'))
    refute(basic.policy_names.include?(nil))
  end

  def test_property_arns
    basic = AwsIamPolicys.new
    assert_kind_of(Array, basic.arns)
    assert(basic.arns.include?('arn:aws:iam::aws:policy/test-policy-1'))
    refute(basic.arns.include?(nil))
  end
end
#=============================================================================#
#                               Test Fixtures
#=============================================================================#
module MAIPPB
  class Empty < AwsIamPolicys::Backend
    def list_policies(query = {})
      OpenStruct.new({ policies: [] })
    end
  end

  class Basic < AwsIamPolicys::Backend
    def list_policies(query = {})
      fixtures = [
        OpenStruct.new({
          policy_name: 'test-policy-1',
          arn: 'arn:aws:iam::aws:policy/test-policy-1',
          default_version_id: 'v1',
          attachment_count: 3,
          is_attachable: true,
        }),
        OpenStruct.new({
          policy_name: 'test-policy-2',
          arn: 'arn:aws:iam::aws:policy/test-policy-2',
          default_version_id: 'v2',
          attachment_count: 0,
          is_attachable: false,
        }),
      ]

      OpenStruct.new({ policies: fixtures })
    end
  end
end
