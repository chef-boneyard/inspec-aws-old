require 'helper'
require 'aws_iam_group'
require 'date'

# MAIGSB = MockAwsIamGroupSingularBackend
# Abbreviation not used outside this file

#=============================================================================#
#                            Constructor Tests
#=============================================================================#
class AwsIamGroupConstructorTest < Minitest::Test

  def setup
    AwsIamGroup::BackendFactory.select(MAIGSB::Empty)
  end

  def test_rejects_empty_params
    assert_raises(ArgumentError) { AwsIamGroup.new }
  end

  def test_accepts_group_name_as_scalar
    AwsIamGroup.new('Whatever')
  end

  def test_accepts_group_name_as_hash
    AwsIamGroup.new(group_name: 'Whatever')
  end

  def test_rejects_unrecognized_params
    assert_raises(ArgumentError) { AwsIamGroup.new(shoe_size: 9) }
  end
end


#=============================================================================#
#                               Search / Recall
#=============================================================================#
class AwsIamGroupRecallTest < Minitest::Test

  def setup
    AwsIamGroup::BackendFactory.select(MAIGSB::Basic)
  end

  def test_search_hit_via_scalar_works
    assert AwsIamGroup.new('Administrator').exists?
  end

  def test_search_hit_via_hash_works
    assert AwsIamGroup.new(group_name: 'Administrator').exists?
  end

  def test_search_miss_is_not_an_exception
    refute AwsIamGroup.new(group_name: 'Whatever').exists?
  end
end

#=============================================================================#
#                               Test Fixtures
#=============================================================================#
module MAIGSB
  class Empty < AwsBackendBase
    def get_group(query = {})
      raise Aws::IAM::Errors::NoSuchEntity.new(nil,nil)
    end
  end

  class Basic < AwsBackendBase
    def get_group(query = {})
      fixtures = [
        OpenStruct.new({
          path: '/',
          group_name: 'Administrator',
          group_id: 'AGPAQWERQWERQWERQWERQ',
          arn: 'arn:aws:iam::111111111111:group/Administrator',
          create_date: DateTime.parse('2017-12-14 05:29:57 UTC')
        }),
        OpenStruct.new({
          path: '/',
          group_name: 'AmazonEC2ReadOnlyAccess',
          group_id: 'AGPAASDFASDFASDFASDFA',
          arn: 'arn:aws:iam::111111111111:group/AmazonEC2ReadOnlyAccess',
          create_date: DateTime.parse('2017-12-15 17:37:14 UTC')
        }),
      ]

      selected = fixtures.select do |group|
        group[:group_name].eql? query[:group_name]
      end

      if selected.empty?
        raise Aws::IAM::Errors::NoSuchEntity.new(nil,nil)
      end

      OpenStruct.new({ group: selected[0] })
    end
  end

end
