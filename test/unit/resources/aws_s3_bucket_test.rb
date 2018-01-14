# encoding: utf-8
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
    assert AwsS3Bucket.new('public').exists?
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
    assert_equal('public', AwsS3Bucket.new('public').bucket_name)
  end

  #--------------------- Region ----------------------------#  
  def test_property_region
    assert_equal('us-east-2', AwsS3Bucket.new('public').region)
    assert_equal('EU', AwsS3Bucket.new('private').region)    
  end

  #---------------------- bucket_acl -------------------------------#
  def test_property_bucket_acl_structure
    bucket_acl = AwsS3Bucket.new('public').bucket_acl

    assert_kind_of(Array, bucket_acl)
    assert(bucket_acl.size > 0)
    assert(bucket_acl.all? { |g| g.respond_to?(:permission)})
    assert(bucket_acl.all? { |g| g.respond_to?(:grantee)})
    assert(bucket_acl.all? { |g| g.grantee.respond_to?(:type)})
  end

  def test_property_bucket_acl_public
    bucket_acl = AwsS3Bucket.new('public').bucket_acl
    
    public_grants = bucket_acl.select do |g|
      g.grantee.type == 'Group' && g.grantee.uri =~ /AllUsers/
    end
    refute_empty(public_grants)
  end

  def test_property_bucket_acl_private
    bucket_acl = AwsS3Bucket.new('private').bucket_acl

    public_grants = bucket_acl.select do |g|
      g.grantee.type == 'Group' && g.grantee.uri =~ /AllUsers/
    end
    assert_empty(public_grants)
    
    auth_users_grants = bucket_acl.select do |g|
      g.grantee.type == 'Group' && g.grantee.uri =~ /AuthenticatedUsers/
    end
    assert_empty(auth_users_grants)
  end

  def test_property_bucket_acl_auth_users
    bucket_acl = AwsS3Bucket.new('auth-users').bucket_acl

    public_grants = bucket_acl.select do |g|
      g.grantee.type == 'Group' && g.grantee.uri =~ /AllUsers/
    end
    assert_empty(public_grants)
    
    auth_users_grants = bucket_acl.select do |g|
      g.grantee.type == 'Group' && g.grantee.uri =~ /AuthenticatedUsers/
    end
    refute_empty(auth_users_grants)
  end
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
      owner_full_control = OpenStruct.new({
        grantee: OpenStruct.new({
          type: 'CanonicalUser',
        }),
        permission: 'FULL_CONTROL',
      })

      buckets = {
        'public' => OpenStruct.new({
          :grants => [
            owner_full_control,
            OpenStruct.new({
              grantee: OpenStruct.new({
                type: 'Group',
                uri: 'http://acs.amazonaws.com/groups/global/AllUsers'
              }),
              permission: 'READ',
            }),
          ]
        }),
        'auth-users' => OpenStruct.new({
          :grants => [
            owner_full_control,
            OpenStruct.new({
              grantee: OpenStruct.new({
                type: 'Group',
                uri: 'http://acs.amazonaws.com/groups/global/AuthenticatedUsers'
              }),
              permission: 'READ',
            }),
          ]
        }),
        'private' => OpenStruct.new({ :grants => [ owner_full_control ] }),
        'logging' => OpenStruct.new({
          :grants => [
            owner_full_control,
            OpenStruct.new({
              grantee: OpenStruct.new({
                type: 'Group',
                uri: 'http://acs.amazonaws.com/groups/global/LogDelivery'
              }),
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
              grantee: OpenStruct.new({
                type: 'CanonicalUser',
              }),
              permission: 'FULL_CONTROL',
            }),
            OpenStruct.new({
              grantee: OpenStruct.new({
                type: 'AmazonCustomerByEmail',
              }),
              permission: 'READ',
            }),
            OpenStruct.new({
              grantee: OpenStruct.new({
                type: 'Group',
                uri: 'http://acs.amazonaws.com/groups/global/AllUsers'
              }),
              permission: 'READ',
            }),
          ]
        }),
        'private_file.jpg' => OpenStruct.new({
          :grants => [
            OpenStruct.new({
              grantee: OpenStruct.new({
                type: 'CanonicalUser',
              }),
              permission: 'FULL_CONTROL',
            }),
          ]
        }),
      }
      objects[query[:key]]
    end

    def get_bucket_location(query)
      buckets = {
        'public' => OpenStruct.new({ location_constraint: 'us-east-2' }),
        'private' => OpenStruct.new({ location_constraint: 'EU' }),
        'logging' => OpenStruct.new({ location_constraint: 'ap-southeast-2' }),
        'auth-users' => OpenStruct.new({ location_constraint: 'ap-southeast-1' }),
      }
      unless buckets.key?(query[:bucket])
        raise Aws::S3::Errors::NoSuchBucket.new(nil, nil)
      end
      buckets[query[:bucket]]
    end
  end
end
