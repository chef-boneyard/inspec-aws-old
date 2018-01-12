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

    describe aws_s3_bucket(bucket_name: 'test_bucket') do
      it { should exist }
      it { should_not be_public }
    end

    describe aws_s3_bucket('test_bucket') do
      it { should exist }
    end

<br>

## Examples

The following examples show how to use this InSpec audit resource.

### Test a buckets permissions

    describe aws_s3_bucket(bucket_name: 'test_bucket') do
      its('permissions.owner') { should cmp ['FULL_CONTROL'] }
      its('permissions.authUsers') { should be_in [] }
      its('permissions.logGroup') { should be_in ['WRITE'] }
      its('permissions.everyone') { should be_in [] }
    end

### Test that a bucket does not have any public objects

    describe aws_s3_bucket(bucket_name: 'test_bucket') do
      it { should_not have_public_objects }
    end

<br>

## Supported Properties

### permissions (Hash)

The `permissions` hash property is used for matching the permissions of specific users.

    describe aws_s3_bucket('test_bucket') do
      # Check examples of 'owner'
      its('permissions.owner') { should be_in ['FULL_CONTROL'] }

      # Check examples of 'authUsers'
      its('permissions.authUsers') { should be_in ['READ'] }

      # Check examples of 'everyone'
      its('permissions.everyone') { should be_in [] }

      # Check examples of the 'logGroup'
      its('permissions.logGroup') { should be_in ['WRITE'] }
    end

### public_objects

The `public_objects` property is used for testing the public objects in a bucket.

    describe aws_s3_bucket('test_bucket') do
      # Check examples of 'public'
      its('public_objects') { should eq [] }
    end

### region

The `public_objects` property is used for testing the public objects in a bucket.

    describe aws_s3_bucket('test_bucket') do
      # Check if the correct region is set
      its('region') { should eq 'us-east-1' }
    end

## Matchers

This InSpec audit resource has the following special matchers. For a full list of available matchers (such as `exist`) please visit our [matchers page](https://www.inspec.io/docs/reference/matchers/).

### have_public_objects (alias: has_public_objects)

The `have_public_objects` matcher tests if the S3 Bucket has any objects that are open to the public. Returns a true if one or more objects in the bucket are public.  If no objects are public returns false.  Please visit https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html for more details on what is public.

    it { should_not have_public_objects }

### public

The `public` matcher tests if the S3 bucket has an ACL permission that allows the public to view the bucket

    it { should_not be_public }
