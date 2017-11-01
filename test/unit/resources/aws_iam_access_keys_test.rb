
require 'aws-sdk'
require 'helper'
require 'aws_iam_access_keys'

#==========================================================#
#                 Constructor Tests                        #
#==========================================================#

class AwsIamAccessKeysConstructorTest < Minitest::Test
  # Reset provider back to the implementation default prior
  # to each test.  Tests must explicitly select an alternate.
  def setup
    AwsIamAccessKeys::AccessKeyProvider.reset
  end

  def test_bare_constructor_does_not_explode
    AwsIamAccessKeys::AccessKeyProvider.select(AlwaysEmptyMAKP)
    AwsIamAccessKeys.new
  end
end

#==========================================================#
#                   Filtering Tests                        #
#==========================================================#

class AwsIamAccessKeysFilterTest < Minitest::Test
  # Reset provider back to the implementation default prior
  # to each test.  Tests must explicitly select an alternate.
  def setup
    AwsIamAccessKeys::AccessKeyProvider.reset
  end

  def test_filter_methods_should_exist
    AwsIamAccessKeys::AccessKeyProvider.select(AlwaysEmptyMAKP)
    resource = AwsIamAccessKeys.new
    [:where, :'exists?'].each do |meth|
      assert_respond_to(resource, meth)
    end
  end

  def test_filter_method_where_should_be_chainable
    AwsIamAccessKeys::AccessKeyProvider.select(AlwaysEmptyMAKP)
    resource = AwsIamAccessKeys.new
    assert_respond_to(resource.where, :where)
  end

  def test_filter_method_exists_should_probe_empty_when_empty
    AwsIamAccessKeys::AccessKeyProvider.select(AlwaysEmptyMAKP)
    resource = AwsIamAccessKeys.new
    refute(resource.exists?)
  end

  def test_filter_method_exists_should_probe_present_when_present
    AwsIamAccessKeys::AccessKeyProvider.select(BasicMAKP)
    resource = AwsIamAccessKeys.new
    assert(resource.exists?)
  end
end

#==========================================================#
#                Filter Criteria Tests                     #
#==========================================================#

class AwsIamAccessKeysFilterCriteriaTest < Minitest::Test
  def setup
    # Here we always want no rseults.
    AwsIamAccessKeys::AccessKeyProvider.select(AlwaysEmptyMAKP)
    @valued_criteria = {
      username: 'bob',
      id: 'AKIA1234567890ABCDEF',
      access_key_id: 'AKIA1234567890ABCDEF',
    }
  end

  def test_criteria_when_used_in_constructor_with_value
    @valued_criteria.each do |criterion, value|
      AwsIamAccessKeys.new(criterion => value)
    end
  end

  def test_criteria_when_used_in_where_with_value
    @valued_criteria.each do |criterion, value|
      AwsIamAccessKeys.new.where(criterion => value)
    end
  end

  # Negative cases
  def test_criteria_when_used_in_constructor_with_bad_criterion
    assert_raises(RuntimeError) do
      AwsIamAccessKeys.new(nope: 'some_val')
    end
  end

  def test_criteria_when_used_in_where_with_bad_criterion
    assert_raises(RuntimeError) do
      AwsIamAccessKeys.new(nope: 'some_val')
    end
  end

  # Identity criterion is allowed based on regex
  def test_identity_criterion_when_used_in_constructor_positive
    AwsIamAccessKeys.new('AKIA1234567890ABCDEF')
  end

  # Permitted by FilterTable?
  def test_identity_criterion_when_used_in_where_positive
    AwsIamAccessKeys.new.where('AKIA1234567890ABCDEF')
  end

  def test_identity_criterion_when_used_in_constructor_negative
    assert_raises(RuntimeError) do
      AwsIamAccessKeys.new('NopeAKIA1234567890ABCDEF')
    end
  end

  # Permitted by FilterTable?
  # def test_identity_criterion_when_used_in_where_negative
  #    assert_raises(RuntimeError) do
  #     AwsIamAccessKeys.new.where('NopeAKIA1234567890ABCDEF')
  #   end
  # end
end

#==========================================================#
#                    Property Tests                        #
#==========================================================#
class AwsIamAccessKeysPropertiesTest < Minitest::Test
  def setup
    # Reset back to empty each time.
    AwsIamAccessKeys::AccessKeyProvider.select(AlwaysEmptyMAKP)
  end

  def test_property_created_date
    AwsIamAccessKeys::AccessKeyProvider.select(BasicMAKP)
    probed = AwsIamAccessKeys.new
    assert_kind_of(DateTime, probed.entries.first.created_date)
    assert_equal(3, probed.entries.count)
    
    arg_filtered = AwsIamAccessKeys.new.where(created_date: DateTime.parse('2017-10-27T17:58:00Z'))
    assert_equal(1, arg_filtered.entries.count)
    assert arg_filtered.access_key_ids.first.end_with?('BOB')

    block_filtered = AwsIamAccessKeys.new.where { created_date.friday? }
    assert_equal(1, block_filtered.entries.count)
    assert block_filtered.access_key_ids.first.end_with?('BOB')
  end

  def test_property_created_days_ago
    AwsIamAccessKeys::AccessKeyProvider.select(BasicMAKP)
    probed = AwsIamAccessKeys.new
    assert_kind_of(Integer, probed.entries.first.created_days_ago)
    assert_equal(3, probed.entries.count)
    
    arg_filtered = AwsIamAccessKeys.new.where(created_days_ago: 9)
    assert_equal(1, arg_filtered.entries.count)
    assert arg_filtered.access_key_ids.first.end_with?('SALLY')

    block_filtered = AwsIamAccessKeys.new.where { created_days_ago > 2 }
    assert_equal(2, block_filtered.entries.count)
  end

  def test_property_created_hours_ago
    AwsIamAccessKeys::AccessKeyProvider.select(BasicMAKP)
    probed = AwsIamAccessKeys.new
    assert_kind_of(Integer, probed.entries.first.created_hours_ago)
    assert_equal(3, probed.entries.count)
    
    arg_filtered = AwsIamAccessKeys.new.where(created_hours_ago: 222)
    assert_equal(1, arg_filtered.entries.count)
    assert arg_filtered.access_key_ids.first.end_with?('SALLY')

    block_filtered = AwsIamAccessKeys.new.where { created_hours_ago > 100 }
    assert_equal(2, block_filtered.entries.count)
  end
end
#==========================================================#
#                 Mock Support Classes                     #
#==========================================================#

# MAKP = MockAccessKeyProvider.  Abbreviation not used
# outside this file.

class AlwaysEmptyMAKP < AwsIamAccessKeys::AccessKeyProvider
  def fetch(_filter_criteria)
    []
  end
end

class BasicMAKP < AwsIamAccessKeys::AccessKeyProvider
  def fetch(_filter_criteria)
    [
      {
        username: 'bob',
        access_key_id: 'AKIA1234567890123BOB',
        id: 'AKIA1234567890123BOB',
        created_date: DateTime.parse('2017-10-27T17:58:00Z'),
        created_days_ago: 4,
        created_hours_ago: 102,
        status: 'Active',
      },
      {
        username: 'sally',
        access_key_id: 'AKIA12345678901SALLY',
        id: 'AKIA12345678901SALLY',
        created_date: DateTime.parse('2017-10-22T17:58:00Z'),
        created_days_ago: 9,
        created_hours_ago: 222,
        status: 'Active',
      },
      {
        username: 'robin',
        access_key_id: 'AKIA12345678901ROBIN',
        id: 'AKIA12345678901ROBIN',
        created_date: DateTime.parse('2017-10-31T17:58:00Z'),
        created_days_ago: 1,
        created_hours_ago: 12,
        status: 'Inactive',
      },
    ]
  end
end
