---
title: About the aws_s3_buckets Resource
---

# aws_s3_buckets

Use the `aws_s3_buckets` InSpec audit resource to test properties of all or a group of  AWS buckets.

To test properties of multiple S3 buckets , use the `aws_s3_buckets` resource.

To test properties of a specific AWS S3 bucket, use the `aws_s3_bucket` resource.

<br>

## Syntax

An `aws_s3_buckets` resource block declares all buckets in an account

    describe aws_s3_buckets.where(availability: 'Public') do
      its('bucket_names') { should be_in [] }
    end

<br>

## Examples

The following examples show how to use this InSpec audit resource.

### Test the names of available buckets

    describe aws_s3_buckets do
      its('bucket_names') { should be_in ['logging_bucket', 'another_bucket'] }
    end

### Test what buckets are public.

A public bucket is any bucket that has a ACL permission given to everyone.
The first test will return what buckets are public on a fail while the second
test will only return true or false.

    describe aws_s3_buckets.where(availability: 'Public') do
      its('bucket_names') { should eq [] }
      # OR
      it { should_not have_public_buckets }
    end

### Test what buckets are private.

A public bucket is any bucket that has no ACL permissions given to everyone in the world.

    describe aws_s3_buckets.where(availability: 'Private') do
      its('bucket_names') { should be_in ['Bucket_name'] }
    end

<br>

## Matchers

This InSpec audit resource has the following special matchers. For a full list of available matchers (such as `exist`) please visit our [matchers page](https://www.inspec.io/docs/reference/matchers/).

### have_public_buckets

The `have_public_buckets` matcher tests if there exists a bucket that is publicly available.

    it { should_not have_public_buckets }
