require 'helper'
require 'aws_kms__key'

# MAKKSB = MockAwsKmsKeyBackend
# Abbreviation not used outside this file

TIME_NOW = Time.now
#=============================================================================#
#                            Constructor Tests
#=============================================================================#
class AwsKmsKeyConstructorTest < Minitest::Test

  def setup
    AwsKmsKey::BackendFactory.select(MAKKSB::Empty)
  end
  
  def test_rejects_empty_params
    assert_raises(ArgumentError) { AwsKmsKey.new }
  end
  
  def test_accepts_key_arn_as_scalar
    AwsKmsKey.new('arn:aws:kms:us-east-1::key/7a6950aa-c8e6-4e51-8afc-111111111111')
  end
  
  def test_accepts_key_arn_as_hash
    AwsKmsKey.new(key_arn: 'arn:aws:kms:us-east-1::key/7a6950aa-c8e6-4e51-8afc-111111111111')
  end
  
  def test_rejects_unrecognized_params
    assert_raises(ArgumentError) { AwsKmsKey.new(invalid: 9) }
  end
end

#=============================================================================#
#                               Search / Recall
#=============================================================================#
class AwsKmsKeyRecallTest < Minitest::Test

  def setup
    AwsKmsKey::BackendFactory.select(MAKKSB::Basic)
  end
  
  def test_search_hit_via_scalar_works
    assert AwsKmsKey.new('arn:aws:kms:us-east-1::key/7a6950aa-c8e6-4e51-8afc-111111111111').exists?
  end
  
  def test_search_hit_via_hash_works
    assert AwsKmsKey.new(key_arn: 'arn:aws:kms:us-east-1::key/7a6950aa-c8e6-4e51-8afc-111111111111').exists?
  end
  
  def test_search_miss_is_not_an_exception
    refute AwsKmsKey.new(key_arn: 'non-existant').exists?
  end
end

#=============================================================================#
#                               Properties
#=============================================================================#
class AwsKmsKeyPropertiesTest < Minitest::Test

  def setup
    AwsKmsKey::BackendFactory.select(MAKKSB::Basic)
  end

  def test_property_key_id
    assert_equal('7a6950aa-c8e6-4e51-8afc-111111111111', AwsKmsKey.new('arn:aws:kms:us-east-1::key/7a6950aa-c8e6-4e51-8afc-111111111111').key_id)
    assert_nil(AwsKmsKey.new(key_arn: 'non-existant').key_id)
  end
  
  def test_property_arn
    assert_equal('arn:aws:kms:us-east-1::key/7a6950aa-c8e6-4e51-8afc-111111111111', AwsKmsKey.new('arn:aws:kms:us-east-1::key/7a6950aa-c8e6-4e51-8afc-111111111111').arn)
    assert_nil(AwsKmsKey.new(key_arn: 'non-existant').arn)
  end
  
  def test_property_creation_date
    assert_equal(TIME_NOW - 10*24*3600, AwsKmsKey.new('arn:aws:kms:us-east-1::key/7a6950aa-c8e6-4e51-8afc-111111111111').creation_date)
    assert_nil(AwsKmsKey.new(key_arn: 'non-existant').creation_date)
  end
  
  def test_property_key_usage
    assert_equal('ENCRYPT_DECRYPT', AwsKmsKey.new('arn:aws:kms:us-east-1::key/7a6950aa-c8e6-4e51-8afc-111111111111').key_usage)
    assert_nil(AwsKmsKey.new(key_arn: 'non-existant').key_usage)
  end
  
  def test_property_key_state
    assert_equal('Enabled', AwsKmsKey.new('arn:aws:kms:us-east-1::key/7a6950aa-c8e6-4e51-8afc-111111111111').key_state)
    assert_nil(AwsKmsKey.new(key_arn: 'non-existant').key_state)
  end
  
  def test_property_description
    assert_equal('test-key-1-desc', AwsKmsKey.new('arn:aws:kms:us-east-1::key/7a6950aa-c8e6-4e51-8afc-111111111111').description)
    assert_nil(AwsKmsKey.new(key_arn: 'non-existant').description)
  end
  
  def test_property_deletion_date
    assert_equal(TIME_NOW + 10*24*3600, AwsKmsKey.new('arn:aws:kms:us-east-1::key/7a6950aa-c8e6-4e51-8afc-111111111111').deletion_date)
    assert_nil(AwsKmsKey.new(key_arn: 'non-existant').deletion_date)
  end
  
  def test_property_valid_to
    assert_equal(nil, AwsKmsKey.new('arn:aws:kms:us-east-1::key/7a6950aa-c8e6-4e51-8afc-111111111111').valid_to)
    assert_nil(AwsKmsKey.new(key_arn: 'non-existant').valid_to)
  end
  
  def test_property_origin
    assert_equal('AWS_KMS', AwsKmsKey.new('arn:aws:kms:us-east-1::key/7a6950aa-c8e6-4e51-8afc-111111111111').origin)
    assert_nil(AwsKmsKey.new(key_arn: 'non-existant').origin)
  end
  
  def test_property_expiration_model
    assert_equal('KEY_MATERIAL_EXPIRES', AwsKmsKey.new('arn:aws:kms:us-east-1::key/7a6950aa-c8e6-4e51-8afc-111111111111').expiration_model)
    assert_nil(AwsKmsKey.new(key_arn: 'non-existant').expiration_model)
  end
  
  def test_property_key_manager
    assert_equal('AWS', AwsKmsKey.new('arn:aws:kms:us-east-1::key/7a6950aa-c8e6-4e51-8afc-111111111111').key_manager)
    assert_nil(AwsKmsKey.new(key_arn: 'non-existant').key_manager)
  end
  
  def test_property_created_days_ago
    assert_equal(10, AwsKmsKey.new('arn:aws:kms:us-east-1::key/7a6950aa-c8e6-4e51-8afc-111111111111').created_days_ago)
    assert_nil(AwsKmsKey.new(key_arn: 'non-existant').created_days_ago)
  end
end

#=============================================================================#
#                               Matchers
#=============================================================================#
class AwsKmsKeyMatchersTest < Minitest::Test

  def setup
    AwsKmsKey::BackendFactory.select(MAKKSB::Basic)
  end
  
  def test_matcher_enabled_positive
    assert AwsKmsKey.new('arn:aws:kms:us-east-1::key/7a6950aa-c8e6-4e51-8afc-111111111111').enabled?
  end

  def test_matcher_enabled_negative
    refute AwsKmsKey.new('arn:aws:kms:us-east-1::key/7a6950aa-c8e6-4e51-8afc-222222222222').enabled?
  end
  
  def test_matcher_rotation_enabled_positive
    assert AwsKmsKey.new('arn:aws:kms:us-east-1::key/7a6950aa-c8e6-4e51-8afc-111111111111').rotation_enabled?
  end

  def test_matcher_rotation_enabled_negative
    refute AwsKmsKey.new('arn:aws:kms:us-east-1::key/7a6950aa-c8e6-4e51-8afc-222222222222').rotation_enabled?
  end
end


#=============================================================================#
#                               Test Fixtures
#=============================================================================#
module MAKKSB
  class Empty < AwsKmsKey::Backend
    def describe_key(query)
      {}
    end
  end

  class Basic < AwsKmsKey::Backend
    def describe_key(query)
      fixtures = [
       OpenStruct.new({
           key_id: "7a6950aa-c8e6-4e51-8afc-111111111111",
           arn: "arn:aws:kms:us-east-1::key/7a6950aa-c8e6-4e51-8afc-111111111111",
           creation_date: TIME_NOW - 10*24*3600,
           enabled: true,
           description: "test-key-1-desc",
           key_usage: "ENCRYPT_DECRYPT",
           key_state: "Enabled",
           deletion_date: TIME_NOW + 10*24*3600,
           valid_to: nil,
           origin: "AWS_KMS",
           expiration_model: 'KEY_MATERIAL_EXPIRES',
           key_manager: "AWS"
        }),
        OpenStruct.new({
           key_id: "7a6950aa-c8e6-4e51-8afc-222222222222",
           arn: "arn:aws:kms:us-east-1::key/7a6950aa-c8e6-4e51-8afc-222222222222",
           creation_date: TIME_NOW,
           enabled: false,
           description: "test-key-2-desc",
           key_usage: '',
           key_state: "PendingDeletion",
           deletion_date: nil,
           valid_to: nil,
           origin: "EXTERNAL",
           expiration_model: 'KEY_MATERIAL_DOES_NOT_EXPIRE',
           key_manager: "CUSTOMER"
        }),
      ]
      selected = fixtures.detect do |fixture|
        fixture.arn == query[:key_id]
      end
      return OpenStruct.new({ key_metadata: selected }) unless selected.nil?
      {}
    end 

    def get_key_rotation_status(query)
      fixtures = [
       OpenStruct.new({
           arn: "arn:aws:kms:us-east-1::key/7a6950aa-c8e6-4e51-8afc-111111111111",
           key_rotation_enabled: true
        }),
        OpenStruct.new({
           arn: "arn:aws:kms:us-east-1::key/7a6950aa-c8e6-4e51-8afc-222222222222",
           key_rotation_enabled: false
        }),
      ]
      selected = fixtures.detect do |fixture|
        fixture.arn == query[:key_id]
      end
      return selected unless selected.nil?
      {}
    end
  end
end