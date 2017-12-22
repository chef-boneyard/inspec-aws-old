---
title: About the aws_s3_bucket Resource
---

# aws_s3_bucket

Use the `aws_s3_bucket` InSpec audit resource to test properties of a single AWS bucket.

To test properties of a multiple S3 buckets , use the `aws_s3_buckets` resource.

To test properties of a specific AWS S3 bucket, use the `aws_s3_bucket` resource.

<br>

## Syntax

An `aws_s3_bucket` resource block declares a bucket by name, and then lists tests to be performed.

    describe aws_s3_bucket(name: 'test_bucket') do
      it { should exist }
    end

<br>

## Examples

The following examples show how to use this InSpec audit resource.

### Test a buckets permissions

    describe aws_s3_bucket(name: 'test_bucket') do
      its('permissions_owner') { should cmp ['FULL_CONTROL'] }
      its('permissions_auth_users') { should cmp [] }
      its('permissions_log_group') { should cmp ['WRITE'] }
      its('permissions_everyone') { should cmp [] }

    end

### Test that a bucket does not have any public files

    describe aws_s3_bucket(name: 'test_bucket') do
      it { should_not have_public_files }
    end

<br>

## Matchers

This InSpec audit resource has the following special matchers. For a full list of available matchers (such as `exist`) please visit our [matchers page](https://www.inspec.io/docs/reference/matchers/).

### have_console_password

The `have_public_files` matcher tests if the S3 Bucket has any files that are open to the public.

    it { should_not have_public_files }
