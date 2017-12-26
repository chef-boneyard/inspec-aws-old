---
title: About the s3_bucket_object Resource
---

# aws_iam_users

Use the `aws_s3_bucket_object` InSpec audit resource to test properties of a all or multiple users.

To test properties of a single user, use the `aws_s3_bucket_object` resource.

To test properties of the specific AWS S3 Bucket (which owns the account), use the `aws_s3_bucket_object` resource.

<br>

## Syntax

An `aws_s3_bucket_object` resource block users a filter to select a group of users and then tests that group

    describe aws_s3_bucket_object(name: 'access_logging', key: 'private_file') do
      it { should_not exist }
      it { should_not be_public }
      its('auth_users_permissions') { should_not cmp [] }
    end

<br>

## Examples

The following examples show how to use this InSpec audit resource.

### Test that the object is not public to everyone.

    describe aws_s3_bucket_object(name: 'access_logging', key: 'private_file') do
      it { should_not be_public }
    end

### Test that no authenticated users have no permissions. Authenticated users are
### considered any one with a AWS account and has a grant to the object.

    describe aws_s3_bucket_object(name: 'access_logging', key: 'private_file') do
      its('auth_users_permissions') { should cmp [] }
    end

<br>

## Matchers

This InSpec audit resource has the following special matchers. For a full list of available matchers (such as `exist`) please visit our [matchers page](https://www.inspec.io/docs/reference/matchers/).

### public

The `public` matcher tests if the object is publicly accessible to everyone.

    it { should be_public }

    ### public
