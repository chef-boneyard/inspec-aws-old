
require 'aws-sdk'
require 'helper'
require 'aws_iam_access_keys'

#==========================================================#
#                 Constructor Tests                        #
#==========================================================#

class AwsIamAccessKeysConstructorTest < Minitest::Test
  def test_bare_constructor_does_not_explode
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
    AwsIamAccessKeys::AccessKeyProvider.select(AwsIamAccessKeys::AccessKeyProvider::DEFAULT_PROVIDER)
  end

  def test_filter_methods_should_exist
    resource = AwsIamAccessKeys.new
    [:where, :exists].each do |meth|
      assert_respond_to(resource, meth)
    end
  end

  def test_filter_method_where_should_be_chainable
    AwsIamAccessKeys::AccessKeyProvider.select(AlwaysEmptyMAKP)
    resource = AwsIamAccessKeys.new
    assert_kind_of(AwsIamAccessKeys, resource.where)
  end

  def test_filter_method_exists_should_probe_empty_when_empty
    AwsIamAccessKeys::AccessKeyProvider.select(AlwaysEmptyMAKP)
    resource = AwsIamAccessKeys.new
    refute(resource.exists)
  end

  def test_filter_method_exists_should_probe_present_when_present
    AwsIamAccessKeys::AccessKeyProvider.select(BasicMAKP)
    resource = AwsIamAccessKeys.new
    assert(resource.exists)
  end
end

#==========================================================#
#                 Mock Support Classes                     #
#==========================================================#

# MAKP = MockAccessKeyProvider.  Abbreviation not used
# outside this file.

class AlwaysEmptyMAKP < AwsIamAccessKeys::AccessKeyProvider
  def fetch
    []
  end
end

class BasicMAKP < AwsIamAccessKeys::AccessKeyProvider
  def fetch
    [
      {
        username: 'bob',
        access_key_id: 'AKIA1234567890ABCDEF',
        created_date: '2017-10-27T17:58:00Z',
        # last_used_date: Time.now,  Seperate API call aws iam get-access-key-last-used --access-key-id ...
        status: 'Active',
      }
    ]
  end
end
