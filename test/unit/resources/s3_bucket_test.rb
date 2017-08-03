require 'helper'
require 's3_bucket'

class TestS3Bucket < Minitest::Test
  Name = 'test'.freeze

  def setup
    @mock_conn = Minitest::Mock.new
    @mock_client = Minitest::Mock.new
    @mock_resource = Minitest::Mock.new

    @mock_conn.expect :s3_bucket_client, @mock_client
    @mock_conn.expect :s3_bucket_resource, @mock_resource
  end

  def test_that_S3_Bucket_returns_name_directly_when_constructed_with_a_name
    assert_equal Name, S3Bucket.new(Name, @mock_conn).name
  end

  def test_that_exists_returns_true_when_bucket_exists
    mock = Minitest::Mock.new
    mock.expect :exists?, true
    @mock_resource.expect :bucket, mock, [Name]
    assert S3Bucket.new(Name, @mock_conn).exists?
  end

end
