---
title: About the aws_kms_key Resource
---

# aws_kms_key

Use the `aws_kms_key` InSpec audit resource to test properties of a single AWS KMS Key.

AWS Key Management Service (AWS KMS) is a managed service that makes it easy for you to create and control the encryption keys used to encrypt your data. AWS KMS lets you create master keys that can never be exported from the service and which can be used to encrypt and decrypt data based on policies you define.

Each AWS KMS Key is uniquely identified by its key_id or key_arn.

<br>

## Syntax

An aws_kms_key resource block identifies a key by key_arn.

    # Find a kms key by name
    describe aws_kms_key('test-key-1-arn') do
      it { should exist }
    end

    # Hash syntax for key arn
    describe aws_kms_key(key_arn: 'test-key-1-arn') do
      it { should exist }
    end

<br>

## Examples

The following examples show how to use this InSpec audit resource.

### Test that the specified key does exist

    describe aws_kms_key('test-key-1-arn') do
      it { should exist }
    end

### Test that the specified key is enabled

    describe aws_kms_key('test-key-1-arn') do
      it { should be_enabled }
    end

### Test that the specified key is rotation enabled

    describe aws_kms_key('test-key-1-arn') do
      it { should be_rotation_enabled }
    end

<br>

## Properties

### key_id

The globally unique identifier for the key.

    describe aws_kms_key('test-key-1-arn') do
      its('key_id') { should cmp "id" }
    end

### arn

The Amazon Resource Name (ARN) of the key.

    describe aws_kms_key('test-key-1-arn') do
      its('arn') { should cmp "arn" }
    end

### creation_date

The date and time when the key was created.

    describe aws_kms_key('test-key-1-arn') do
      its('creation_date') { should cmp date }
    end

### created_days_ago

Number of days since the key was created.

    describe aws_kms_key('test-key-1-arn') do
      its('created_days_ago') { should cmp > 10 }
    end


### key_usage

The cryptographic operations for which you can use the key. Currently the only allowed value is ENCRYPT_DECRYPT , which means you can use the key for the encrypt and decrypt operations.

    describe aws_kms_key('test-key-1-arn') do
      its('key_usage') { should cmp "ENCRYPT_DECRYPT" }
    end

### key_state

The state of the key one of "Enabled", "Disabled", "PendingDeletion", "PendingImport".

    describe aws_kms_key('test-key-1-arn') do
      its('key_state') { should cmp "Enabled" }
    end

### description

The description of the key.

    describe aws_kms_key('test-key-1-arn') do
      its('description') { should cmp "key-description" }
    end

### deletion_date

The date and time after which AWS KMS deletes the key. This value is present only when KeyState is PendingDeletion , otherwise this value is omitted.

    describe aws_kms_key('test-key-1-arn') do
      its('deletion_date') { should cmp date }
    end

### valid_to

The time at which the imported key material expires. When the key material expires, AWS KMS deletes the key material and the key becomes unusable. This value is present only for keys whose Origin is EXTERNAL and whose ExpirationModel is KEY_MATERIAL_EXPIRES , otherwise this value is omitted.

    describe aws_kms_key('test-key-1-arn') do
      its('valid_to') { should cmp date }
    end

### origin

The source of the key's key material. When this value is AWS_KMS, AWS KMS created the key material. When this value is EXTERNAL , the key material was imported from your existing key management infrastructure or the key lacks key material.


    describe aws_kms_key('test-key-1-arn') do
      its('origin') { should cmp "AWS_KMS" }
    end

### expiration_model

Specifies whether the key's key material expires. This value is present only when Origin is EXTERNAL , otherwise this value is omitted.

    describe aws_kms_key('test-key-1-arn') do
      its('expiration_model') { should cmp "KEY_MATERIAL_EXPIRES" }
    end

### key_manager

The key's manager keys are either customer-managed or AWS-managed.

    describe aws_kms_key('test-key-1-arn') do
      its('key_manager') { should cmp "AWS" }
    end


## Matchers

This InSpec audit resource has the following special matchers. For a full list of available matchers (such as `exist`) please visit our [matchers page](https://www.inspec.io/docs/reference/matchers/).


### be_enabled

Checks whether the specified key is enabled.

    describe aws_kms_key('test-key-1-arn') do
      it { should be_enabled }
    end


### be_rotation_enabled

Checks whether automatic rotation of the key material is enabled for the specified key.

    describe aws_kms_key('test-key-1-arn') do
      it { should be_rotation_enabled }
    end

