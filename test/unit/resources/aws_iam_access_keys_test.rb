
require 'aws-sdk'
require 'helper'
require 'aws_iam_access_keys'

class AwsIamAccessKeysTest < Minitest::Test
  def test_bare_constructor_does_not_explode
    AwsIamAccessKeys.new
  end
end
