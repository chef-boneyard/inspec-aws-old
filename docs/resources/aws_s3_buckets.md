---
title: About the aws_s3_buckets Resource
---

# aws_s3_buckets

Use the `aws_s3_buckets` InSpec audit resource to test properties of all AWS buckets/

To test properties of a multiple S3 buckets , use the `aws_s3_buckets` resource.

To test properties of a specific AWS S3 bucket, use the `aws_s3_bucket` resource.

<br>

## Syntax

An `aws_s3_buckets` resource block declares all buckets in an account

    describe aws_s3_buckets do
      its('buckets') { should be-in ['logging_bucket', 'another_bucket'] }
      it { should_not have_public_buckets }
    end

<br>

## Examples

The following examples show how to use this InSpec audit resource.

### Test the names of available buckets

    describe aws_s3_buckets do
      its('buckets') { should be-in ['logging_bucket', 'another_bucket'] }
    end

<br>

## Matchers

This InSpec audit resource has the following special matchers. For a full list of available matchers (such as `exist`) please visit our [matchers page](https://www.inspec.io/docs/reference/matchers/).

### have_public_buckets

The `have_public_buckets` matcher tests if there exists a bucket that is publicly available.

    it { should_not have_public_buckets }
