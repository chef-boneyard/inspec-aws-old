---
title: About the aws_kms_keys Resource
---

# aws_kms_keys

Use the `aws_kms_keys` InSpec audit resource to test properties of some or all AWS KMS Keys.

AWS Key Management Service (KMS) is a managed service that makes it easy for you to create and control the encryption keys used to encrypt your data, and uses Hardware Security Modules (HSMs) to protect the security of your keys. AWS Key Management Service is integrated with several other AWS services to help you protect the data you store with these services.

Each AWS KMS Key is uniquely identified by its key-id or key-arn.

<br>

## Syntax

An `aws_kms_keys` resource block uses an optional filter to select a group of KMS Keys and then tests that group.

    # Verify the number of KMS keys in the AWS account
    describe aws_kms_keys do
      its('entries.count') { should cmp 10 }
    end

<br>

## Examples

The following examples show how to use this InSpec audit resource.

As this is the initial release of `aws_kms_keys`, its limited functionality precludes examples.

<br>

## Matchers

### exists

The control will pass if the filter returns at least one result. Use should_not if you expect zero matches.

    # Verify that at least one KMS Key exists.
    describe aws_kms_keys
      it { should exist }
    end   

## Properties

### key_arns

Provides a list of key arns for all KMS Keys in the AWS account.

    describe aws_kms_keys do
      its('key_arns') { should include('arn:aws:kms:us-east-1::key/key-id') }
    end

### key_ids

Provides a list of key ids for all KMS Keys in the AWS account.

    describe aws_kms_keys do
      its('key_ids') { should include('fd7e608b-f435-4186-b8b5-111111111111') }
    end

### entries

Provides access to the raw results of the query.  This can be useful for checking counts and other advanced operations.

    # Allow at most 100 KMS Keys on the account
    describe aws_kms_keys do
      its('entries.count') { should be <= 100}
    end
