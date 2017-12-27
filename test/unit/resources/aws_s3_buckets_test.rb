# encoding: utf-8
require 'ostruct'
require 'helper'
require 'aws_s3_buckets'

# MSBMB = MockS3BucketsMultipleBackend
# Abbreviation not used outside this file

#=============================================================================#
#                            Constructor Tests
#=============================================================================#
class AwsS3BucketsConstructor < Minitest::Test
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
#                               Properties
#=============================================================================#

class AwsS3BucketsConstructor < Minitest::Test
  def setup
    AwsS3Buckets::BackendFactory.select(AwsMSBMB::Basic)
  end

  def test_property_buckets
    assert_equal(['Public Bucket', 'Private Bucket'], AwsS3Buckets.new.buckets)
  end

  def test_public_buckets
    assert_equal(true, AwsS3Buckets.new.has_public_buckets)
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
      buckets[query[:bucket]][:grants]
    end
  end
end
