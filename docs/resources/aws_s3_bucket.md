---
title: About the aws_s3_bucket Resource
---

# aws_s3_bucket

Use the `aws_s3_bucket` InSpec audit resource to test properties of a single AWS bucket.

To test properties of a multiple S3 buckets, use the `aws_s3_buckets` resource.

<br>

## Limitations

S3 bucket security is a complex matter.  For details on how AWS evaluates requests for access, please see [the AWS documentation](https://docs.aws.amazon.com/AmazonS3/latest/dev/how-s3-evaluates-access-control.html).  S3 buckets and the objects they contain support three different types of access control: bucket ACLs, bucket policies, and object ACLs.

As of January 2018, this resource supports evaluating bucket ACLs and bucket policies. We do not support evaluating object ACLs because it introduces scalability concerns in the AWS API; we recommend using AWS mechanisms such as CloudTrail and Config to detect insecure object ACLs.

In particular, users of the `be_public` matcher should carefully examine the conditions under which the matcher will detect an insecure bucket.  See the `be_public` section under the Matchers section below.

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

    describe aws_s3_bucket('test_bucket') do
      its('bucket_acl.count') { should eq 1 }
    end

### Check to see if a bucket has a bucket policy

    describe aws_s3_bucket('test_bucket') do
      its('bucket_policy') { should be_empty }
    end

### Check to see if a bucket appears to be exposed to the public

    # See Limitations section above
    describe aws_s3_bucket('test_bucket') do
      it { should_not be_public }
    end
<br>

## Supported Properties

### region

The `region` property identifies the AWS Region in which the S3 bucket is located.

    describe aws_s3_bucket('test_bucket') do
      # Check if the correct region is set
      its('region') { should eq 'us-east-1' }
    end

## Unsupported Properties

### bucket_acl

The `bucket_acl` property is a low-level property that lists the individual Bucket ACL grants that are in effect on the bucket.  Other higher-level properties, such as be\_public, are more concise and easier to use.  You can use the `bucket_acl` property to investigate which grants are in effect, causing be\_public to fail.

The value of bucket_acl is an Array of simple objects.  Each object has a `permission` property and a `grantee` property.  The `permission` property will be a string such as 'READ', 'WRITE' etc (See the [AWS documentation](https://docs.aws.amazon.com/sdkforruby/api/Aws/S3/Client.html#get_bucket_acl-instance_method) for a full list).  The `grantee` property contains sub-properties, such as `type` and `uri`.

    
    bucket_acl = aws_s3_bucket('my-bucket')

    # Look for grants to "AllUsers" (that is, the public)
    all_users_grants = bucket_acl.select do |g|
      g.grantee.type == 'Group' && g.grantee.uri =~ /AllUsers/
    end

    # Look for grants to "AuthenticatedUsers" (that is, any authenticated AWS user - nearly public)
    auth_grants = bucket_acl.select do |g|
      g.grantee.type == 'Group' && g.grantee.uri =~ /AuthenticatedUsers/
    end

### bucket_policy

The `bucket_policy` is a low-level property that describes the IAM policy document controlling access to the bucket. The `bucket_policy` property returns a Ruby structure that you can probe to check for particular statements.  We recommend using a higher-level property, such as `be_public`, which is concise and easier to implement in your policy files.

The `bucket_policy` property returns an Array of simple objects, each object being an IAM Policy Statement. See the [AWS documentation](https://docs.aws.amazon.com/AmazonS3/latest/dev/example-bucket-policies.html#example-bucket-policies-use-case-2) for details about the structure of this data.

If there is no bucket policy, this property will return an empty Array.

    bucket_policy = aws_s3_bucket('my-bucket')

    # Look for statements that allow the general public to do things
    # This may be a false positive;  it's possible these statements
    # could be protected by conditions, such as IP restrictions.
    public_statements = bucket_policy.select do |s|
      s.effect == 'Allow' && s.principal == '*'
    end

## Matchers

This InSpec audit resource has the following special matchers. For a full list of available matchers (such as `exist`) please visit our [matchers page](https://www.inspec.io/docs/reference/matchers/).

### be_public

The `be_public` matcher tests if the bucket has potentially insecure access controls. This high-level matcher detects several insecure conditions, which may be enhanced in the future. Currently, the matcher reports an insecure bucket if any of the following conditions are met:

  1. A bucket ACL grant exists for the 'AllUsers' group
  2. A bucket ACL grant exists for the 'AuthenticatedUsers' group
  3. A bucket policy has an effect 'Allow' and principal '*'

Note: This resource does not detect insecure object ACLs.

    it { should_not be_public }

### have_access_logging_enabled

The `have_access_logging_enabled` matcher tests if access logging is enabled for the s3 bucket.

    it { should have_access_logging_enabled }
