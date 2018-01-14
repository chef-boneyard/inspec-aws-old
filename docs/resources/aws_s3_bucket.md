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

### Test a bucket's bucket-level ACL

    describe aws_s3_bucket(bucket_name: 'test_bucket') do
      its('bucket_acl.count') { should eq 1 }
    end

### Test that a bucket does not have any public objects

    describe aws_s3_bucket(bucket_name: 'test_bucket') do
      it { should_not have_public_objects }
    end

<br>

## Supported Properties

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

## Unsupported Properties

### bucket_acl

The `bucket_acl` property is a low-level property that lists the individual Bucket ACL grants that are in effect on the bucket.  Other higher-level properties, such as is\_public, are more concise and easier to use.  You can use the `bucket_acl` property to investigate which grants are in efffect, causing is\_public to fail.

The value of bucket_acl is an Array of simple objects.  Each object has a `permission` property and a `grantee` property.  The `permission` property will be a string such as 'READ', 'WRITE' etc (See the [AWS documentation](https://docs.aws.amazon.com/sdkforruby/api/Aws/S3/Client.html#get_bucket_acl-instance_method) for a full list).  The `grantee` property contains sub-properties, such as `type` and `uri`.

    
    bucket_acl = aws_s3_bucket('my-bucket')

    # Look for grants to "AllUsers" (that is, the public)
    all_users_grants = bucket_acl.select do |g|
      g.grantee.type == 'Group' && g.grantee.uri =~ /AllUsers/
    end

    # Look for grants to "AuthenticatedUsers" (that is, any authenticated AWS user - nearly public)
    all_users_grants = bucket_acl.select do |g|
      g.grantee.type == 'Group' && g.grantee.uri =~ /AuthenticatedUsers/
    end

## Matchers

This InSpec audit resource has the following special matchers. For a full list of available matchers (such as `exist`) please visit our [matchers page](https://www.inspec.io/docs/reference/matchers/).

### have_public_objects (alias: has_public_objects)

The `have_public_objects` matcher tests if the S3 Bucket has any objects that are open to the public. Returns a true if one or more objects in the bucket are public.  If no objects are public returns false.  Please visit https://docs.aws.amazon.com/AmazonS3/latest/dev/acl-overview.html for more details on what is public.

    it { should_not have_public_objects }

### public

The `public` matcher tests if the S3 bucket has an ACL permission that allows the public to view the bucket

    it { should_not be_public }
