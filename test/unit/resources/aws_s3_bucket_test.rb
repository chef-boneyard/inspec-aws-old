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
    AwsS3Bucket.new('test_bucket')
  end

  def test_constructor_expected_well_formed_args
    {
      name: 'test_bucket',
    }.each do |param, value|
      AwsS3Bucket.new(param => value)
    end
  end

  def test_constructor_reject_unknown_resource_params
    assert_raises(ArgumentError) { AwsS3Bucket.new(bla: 'blabla') }
  end
end

#=============================================================================#
#                               Properties
#=============================================================================#

class AwsS3BucketConstructor < Minitest::Test
  def setup
    AwsS3Bucket::BackendFactory.select(AwsMSBSB::Basic)
  end

  def test_property_name
    assert_equal('Public Bucket', AwsS3Bucket.new('Public Bucket').name)
    assert_nil(AwsS3Bucket.new(name: 'My Bucket').name)
  end

  # def test_property_permissions
  #   assert_equal(['FULL_CONTROL', 'READ'], AwsS3Bucket.new('Public Bucket').permissions)
  #   assert_nil(AwsS3Bucket.new('My Bucket').permissions)
  # end

  def test_property_has_public_files
    assert_equal(true, AwsS3Bucket.new('Public Bucket').has_public_files)
    assert_nil(AwsS3Bucket.new('My Bucket').has_public_files)
  end

  def test_property_policy
    assert_equal('', AwsS3Bucket.new('Public Bucket').policy)
    assert_nil(AwsS3Bucket.new('My Bucket').policy)
  end

end

#=============================================================================#
#                               Test Fixtures
#=============================================================================#

module AwsMSBSB
  class Basic < AwsS3Bucket::Backend
    def list_objects(query)
      objects = [
          OpenStruct.new({
            key: 'public_file.jpg',
        }),
        OpenStruct.new({
          key: 'private_file.jpg',
        }),
      ]

      OpenStruct.new({ contents: objects })
    end

    def get_bucket_acl(query)
      fixtures = [
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
            uri: 'http://acs.amazonaws.com/groups/global/LogDelivery'
          },
          permission: ['WRITE'],
        }),
        OpenStruct.new({
          grantee: {
            type: 'Group',
            uri: 'http://acs.amazonaws.com/groups/global/AllUsers'
          },
          permission: ['READ'],
        }),
      ]

      OpenStruct.new({ grants: fixtures })
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
      #puts objects[query[:key]]
      objects[query[:key]]
    end

    def get_bucket_policy(query)
      fixtures = [
        OpenStruct.new({
          policy: '',
        }),
        OpenStruct.new({
          policy: '',
        }),
      ]

      OpenStruct.new({ policies: fixtures })
    end
  end
end
