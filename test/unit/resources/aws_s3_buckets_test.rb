# encoding: utf-8
require 'ostruct'
require 'helper'
require 'aws_s3_buckets'

# MSBMB = MockS3BucketsMultipleBackend
# Abbreviation not used outside this file

#=============================================================================#
#                            Constructor Tests
#=============================================================================#
class AwsS3BucketsConstructorTests < Minitest::Test
  def setup
    AwsS3Buckets::BackendFactory.select(AwsMSBMB::Basic)
  end


  def test_constructor_expected_no_args
    AwsS3Buckets.new
  end

  def test_constructor_reject_unknown_resource_params
    assert_raises(ArgumentError) { AwsS3Buckets.new(bla: 'blabla') }
  end
end

#=============================================================================#
#                            Recall Tests
#=============================================================================#
class AwsS3BucketsRecallTests < Minitest::Test
  def setup
    AwsS3Buckets::BackendFactory.select(AwsMSBMB::Basic)
  end

  def test_exists
    assert_equal(true, AwsS3Buckets.new.where(bucket_name: 'Public Bucket').exists?)
    assert_equal(true, AwsS3Buckets.new.where(bucket_name: 'Private Bucket').exists?)
  end

  def test_doesnt_exist
    assert_equal(false, AwsS3Buckets.new.where(bucket_name: 'NonExistentBucket').exists?)
  end
end

#=============================================================================#
#                               Properties Tests
#=============================================================================#

class AwsS3BucketsPropertiesTest < Minitest::Test
  def setup
    AwsS3Buckets::BackendFactory.select(AwsMSBMB::Basic)
  end

  def test_filter_public_buckets
    assert_equal(['Public Bucket'], AwsS3Buckets.new.where(availability: 'Public').bucket_names)
  end

  def test_filter_private_buckets
    assert_equal(['Private Bucket'], AwsS3Buckets.new.where(availability: 'Private').bucket_names)
  end

  def test_filter_bucket_names
    assert_equal(['Public Bucket', 'Private Bucket'], AwsS3Buckets.new.bucket_names)
  end
end

#=============================================================================#
#                               Matchers Tests
#=============================================================================#

class AwsS3BucketsMatchersTest < Minitest::Test
  def setup
    AwsS3Buckets::BackendFactory.select(AwsMSBMB::Basic)
  end

  def test_matcher_has_public_buckets
    assert_equal(true, AwsS3Buckets.new.has_public_buckets?)
    assert_equal(true, AwsS3Buckets.new.have_public_buckets?)
  end
end

#=============================================================================#
#                               Test Fixtures
#=============================================================================#

module AwsMSBMB
  class Basic < AwsS3Buckets::Backend
    def list_buckets
      object = OpenStruct.new({
        :buckets => [
          OpenStruct.new({
            creation_date: Time.parse("2017-02-15T21: 03: 08.000Z"),
            name: "Public Bucket",
          }),
          OpenStruct.new({
            creation_date: Time.parse("2016-07-24T19: 33: 54.000Z"),
            name: "Private Bucket",
          }),
        ],
        :owner => OpenStruct.new({
          display_name: "owner_name",
          id: "examplee7a2f25102679df27bb0ae12b3f85be6f290b936c4393484be31",
        }),
      })
      object
    end

    def get_bucket_acl(query)
      buckets = {
        'Public Bucket' => OpenStruct.new({
          :grants => [
            OpenStruct.new({
              grantee: {
                type: 'CanonicalUser',
              },
              permission: 'FULL_CONTROL',
            }),
            OpenStruct.new({
              grantee: {
                type: 'AmazonCustomerByEmail',
              },
              permission: 'READ',
            }),
            OpenStruct.new({
              grantee: {
                type: 'Group',
                uri: 'http://acs.amazonaws.com/groups/global/LogDelivery'
              },
              permission: 'WRITE',
            }),
            OpenStruct.new({
              grantee: {
                type: 'Group',
                uri: 'http://acs.amazonaws.com/groups/global/AllUsers'
              },
              permission: 'READ',
            }),
          ]
        }),
        'Private Bucket' => OpenStruct.new({
          :grants => [
            OpenStruct.new({
              grantee: {
                type: 'CanonicalUser',
              },
              permission: 'FULL_CONTROL',
            }),
          ]
        }),
        'Log Bucket' => OpenStruct.new({
          :grants => [
            OpenStruct.new({
              grantee: {
                type: 'CanonicalUser',
              },
              permission: 'FULL_CONTROL',
            }),
            OpenStruct.new({
              grantee: {
                type: 'Group',
                uri: 'http://acs.amazonaws.com/groups/global/LogDelivery'
              },
              permission: 'WRITE',
            }),
          ]
        }),
      }
      buckets[query[:bucket]]
    end
  end
end
