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
      its('permissions.owner') { should cmp ['FULL_CONTROL'] }
      its('permissions.authUsers') { should be_in [] }
      its('permissions.logGroup') { should be_in ['WRITE'] }
      its('permissions.everyone') { should be_in [] }

    end

### Test that a bucket does not have any public files

    describe aws_s3_bucket(name: 'test_bucket') do
      it { should_not have_public_files }
    end

<br>

## Supported Properties

### permissions (Hash)

The `permissions` hash property is used for matching the permissions of specific users.

    describe aws_s3_bucket('test_bucket') do
      # Check what extension categories we have
      its('permissions') { should include 'owner' }
      its('permissions') { should include 'authUsers' }
      its('permissions') { should include 'everyone' }
      its('permissions') { should include 'logGroup' }

      # Check examples of 'owner'
      its('permissions.owner') { should be_in ['FULL_CONTROL'] }

      # Check examples of 'authUsers'
      its('permissions.authUsers') { should be_in ['READ'] }

      # Check examples of 'everyone'
      its('permissions.everyone') { should be_in [] }

      # Check examples of the 'logGroup'
      its('permissions.logGroup') { should be_in ['WRITE'] }
    end

## Matchers

This InSpec audit resource has the following special matchers. For a full list of available matchers (such as `exist`) please visit our [matchers page](https://www.inspec.io/docs/reference/matchers/).

### have_public_files (alias: has_public_files)

The `have_public_files` matcher tests if the S3 Bucket has any files that are open to the public. Returns a true if one or more objects in the bucket are public.  If no objects are public returns false.  Please visit https://blog.rackspace.com/3-things-aws-s3-security-stay-headlines for more details on what is public.

    it { should_not have_public_files }
