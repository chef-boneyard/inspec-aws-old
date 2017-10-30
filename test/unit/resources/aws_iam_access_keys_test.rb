
require 'aws-sdk'
require 'helper'
require 'aws_iam_access_keys'

class AwsIamAccessKeysConstructorTest < Minitest::Test
  def test_bare_constructor_does_not_explode
    AwsIamAccessKeys.new
  end
end

class AwsIamAccessKeysFilterTest < Minitest::Test
  def test_filter_method_where_should_exist
    resource = AwsIamAccessKeys.new
    assert_respond_to(resource, :where)
  end
end
