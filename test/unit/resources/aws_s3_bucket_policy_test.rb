# encoding: utf-8
require 'ostruct'
require 'helper'
require 'aws_s3_bucket_policy'

# MSBPSB = MockS3BucketPolicySingleBackend
# Abbreviation not used outside this file

#=============================================================================#
#                            Constructor Tests
#=============================================================================#
class AwsS3BucketPolcyConstructor < Minitest::Test
  def setup
    AwsS3BucketPolicy::BackendFactory.select(AwsMSBPSB::Basic)
  end

  def test_constructor_no_args_raises
    assert_raises(ArgumentError) { AwsS3BucketPolicy.new }
  end

  def test_constructor_accept_scalar_param
    AwsS3BucketPolicy.new('Public Bucket')
  end

  def test_constructor_expected_well_formed_args
    {
      name: 'Public Bucket',
    }.each do |param, value|
      AwsS3BucketPolicy.new(param => value)
    end
  end

  def test_constructor_reject_unknown_resource_params
    assert_raises(ArgumentError) { AwsS3BucketPolicy.new(bla: 'blabla') }
  end
end

#=============================================================================#
#                               Properties
#=============================================================================#

class AwsS3BucketPolicyConstructor < Minitest::Test
  def setup
    AwsS3BucketPolicy::BackendFactory.select(AwsMSBPSB::Basic)
  end

  def test_property_name
    assert_equal('Public Bucket', AwsS3BucketPolicy.new('Public Bucket').name)
  end

  def test_property_has_statement_allow_all
    assert_equal(true, AwsS3BucketPolicy.new('Public Bucket').has_statement_allow_all)
    assert_equal(false, AwsS3BucketPolicy.new('Private Bucket').has_statement_allow_all)
  end

end

#=============================================================================#
#                               Test Fixtures
#=============================================================================#

module AwsMSBPSB
  class Basic < AwsS3BucketPolicy::Backend
    def get_bucket_policy(query)
      buckets = {
        'Public Bucket' => OpenStruct.new({
          policy: StringIO.new("{\"Version\":\"2008-10-17\",\"Id\":\"LogPolicy\",\"Statement\":[{\"Sid\":\"Enables the log delivery group to publish logs to your bucket \",\"Effect\":\"Allow\",\"Principal\":\"*\",\"Action\":[\"s3:GetBucketAcl\",\"s3:GetObjectAcl\",\"s3:PutObject\"],\"Resource\":[\"arn:aws:s3:::policytest1/*\",\"arn:aws:s3:::policytest1\"]}]}"),
        }),
        'Private Bucket' => OpenStruct.new({
          policy: StringIO.new("{\"Version\":\"2008-10-17\",\"Id\":\"LogPolicy\",\"Statement\":[{\"Sid\":\"Enables the log delivery group to publish logs to your bucket \",\"Effect\":\"Allow\",\"Principal\":{\"AWS\":\"111122223333\"},\"Action\":[\"s3:GetBucketAcl\",\"s3:GetObjectAcl\",\"s3:PutObject\"],\"Resource\":[\"arn:aws:s3:::policytest1/*\",\"arn:aws:s3:::policytest1\"]}]}"),
        }),
      }
      buckets[query[:bucket]]
    end
  end
end
