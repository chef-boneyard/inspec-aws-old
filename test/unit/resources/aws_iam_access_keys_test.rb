
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
        access_key_id: 'AKIA1234567890ABCDEF',
        created_date: '2017-10-27T17:58:00Z',
        # last_used_date: requires separate API call
        status: 'Active',
      },
    ]
  end
end
