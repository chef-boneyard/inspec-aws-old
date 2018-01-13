# encoding: utf-8
require 'ostruct'
require 'helper'
require 'aws_s3_bucket'

# MSBSB = MockS3BucketSingleBackend
# Abbreviation not used outside this file

#=============================================================================#
#                            Constructor Tests
#=============================================================================#
class AwsS3BucketConstructor < Minitest::Test
  def setup
    AwsS3Bucket::BackendFactory.select(AwsMSBSB::Basic)
  end

  def test_constructor_no_args_raises
    assert_raises(ArgumentError) { AwsS3Bucket.new }
  end

  def test_constructor_accept_scalar_param
    AwsS3Bucket.new('some-bucket')
  end

  def test_constructor_accept_hash
    AwsS3Bucket.new(bucket_name: 'some-bucket')
  end

  def test_constructor_reject_unknown_resource_params
    assert_raises(ArgumentError) { AwsS3Bucket.new(bla: 'blabla') }
  end
end

#=============================================================================#
#                               Search / Recall
#=============================================================================#
class AwsS3BucketPropertiesTest < Minitest::Test
  def setup
    AwsS3Bucket::BackendFactory.select(AwsMSBSB::Basic)
  end

  def test_recall_no_match_is_no_exception
    refute AwsS3Bucket.new('NonExistentBucket').exists?
  end

  def test_recall_match_single_result_works
    assert AwsS3Bucket.new('alpha').exists?
  end

  # No need to handle multiple hits; S3 bucket names are globally unique.
end

#=============================================================================#
#                               Properties
#=============================================================================#

class AwsS3BucketPropertiesTest < Minitest::Test
  def setup
    AwsS3Bucket::BackendFactory.select(AwsMSBSB::Basic)
  end

  #---------------------Bucket Name----------------------------#  
  def test_property_bucket_name
    assert_equal('alpha', AwsS3Bucket.new('alpha').bucket_name)
  end

  #--------------------- Region ----------------------------#  
  def test_property_region
    assert_equal('us-east-2', AwsS3Bucket.new('alpha').region)
    assert_equal('EU', AwsS3Bucket.new('beta').region)    
  end

  #-----------------------------------------------------#
  # Testing Properties of a public bucket
  #-----------------------------------------------------#
  # def test_property_permissions_public
  #   assert_equal(['FULL_CONTROL'], AwsS3Bucket.new('Public Bucket').permissions.owner)
  #   assert_equal(['READ'], AwsS3Bucket.new('Public Bucket').permissions.authUsers)
  #   assert_equal(['READ'], AwsS3Bucket.new('Public Bucket').permissions.everyone)
  #   assert_equal(['WRITE'], AwsS3Bucket.new('Public Bucket').permissions.logGroup)
  # end

  # #-----------------------------------------------------#
  # # Testing Properties of a private bucket
  # #-----------------------------------------------------#
  # def test_property_permissions_private
  #   assert_equal(['FULL_CONTROL'], AwsS3Bucket.new('Private Bucket').permissions.owner)
  #   assert_equal([], AwsS3Bucket.new('Private Bucket').permissions.authUsers)
  #   assert_equal([], AwsS3Bucket.new('Private Bucket').permissions.everyone)
  #   assert_equal([], AwsS3Bucket.new('Private Bucket').permissions.logGroup)
  # end

  # #-----------------------------------------------------#
  # # Testing Properties of a log bucket
  # #-----------------------------------------------------#
  # def test_property_permissions_log
  #   assert_equal(['FULL_CONTROL'], AwsS3Bucket.new('Log Bucket').permissions.owner)
  #   assert_equal([], AwsS3Bucket.new('Log Bucket').permissions.authUsers)
  #   assert_equal([], AwsS3Bucket.new('Log Bucket').permissions.everyone)
  #   assert_equal(['WRITE'], AwsS3Bucket.new('Log Bucket').permissions.logGroup)
  # end
end

#=============================================================================#
#                               Test Matchers
#=============================================================================#

class AwsS3BucketPropertiesTest < Minitest::Test
  def setup
    AwsS3Bucket::BackendFactory.select(AwsMSBSB::Basic)
  end

  # def test_matcher_has_public_files
  #   assert_equal(true, AwsS3Bucket.new('Public Bucket').has_public_objects)
  #   assert_equal(false, AwsS3Bucket.new('Private Bucket').has_public_objects)
  #   assert_equal([], AwsS3Bucket.new('Private Bucket').public_objects)
  # end

end

#=============================================================================#
#                               Test Fixtures
#=============================================================================#

module AwsMSBSB
  class Basic < AwsS3Bucket::Backend
    def list_objects(query)
      buckets = {
        'Public Bucket' => OpenStruct.new({
          :contents => [
            OpenStruct.new({
              key: 'public_file.jpg',
            }),
          ]
        }),
        'Private Bucket' => OpenStruct.new({
          :contents => [
            OpenStruct.new({
              key: 'private_file.jpg',
            }),
          ]
        }),
        'Log Bucket' => OpenStruct.new({
          :contents => [
          ]
        }),
      }
      buckets[query[:bucket]]
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

    def get_object_acl(query)
      objects = {
        'public_file.jpg' => OpenStruct.new({
          :grants => [
            OpenStruct.new({
              grantee: {
                type: 'CanonicalUser',
              },
              permission: ['FULL_CONTROL'],
            }),
            OpenStruct.new({
              grantee: {
                type: 'AmazonCustomerByEmail',
              },
              permission: ['READ'],
            }),
            OpenStruct.new({
              grantee: {
                type: 'Group',
                uri: 'http://acs.amazonaws.com/groups/global/AllUsers'
              },
              permission: ['READ'],
            }),
          ]
        }),
        'private_file.jpg' => OpenStruct.new({
          :grants => [
            OpenStruct.new({
              grantee: {
                type: 'CanonicalUser',
              },
              permission: ['FULL_CONTROL'],
            }),
          ]
        }),
      }
      objects[query[:key]]
    end

    def get_bucket_location(query)
      buckets = {
        'alpha' => OpenStruct.new({
          location_constraint: 'us-east-2'
        }),
        'beta' => OpenStruct.new({
          location_constraint: 'EU'
        })
      }
      unless buckets.key?(query[:bucket])
        raise Aws::S3::Errors::NoSuchBucket.new(nil, nil)
      end
      buckets[query[:bucket]]
    end
  end
end
