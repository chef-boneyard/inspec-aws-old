---
title: About the aws_s3_bucket_policy Resource
---

# aws_s3_bucket_policy

Use the `aws_s3_bucket_policy` InSpec audit resource to test properties of a single AWS buckets policy.

<br>

## Syntax

An `aws_s3_bucket_policy` resource block declares a bucket by name, and then lists tests to be performed.

    describe aws_s3_bucket_policy(name: 'test_bucket') do
      it { should_not have_statement_allow_all }
    end

<br>

## Examples

The following examples show how to use this InSpec audit resource.


### Test that a bucket's policy does not have any statements with effect set to 'allow' and 'principal' set to  ' * '

    describe aws_s3_bucket_policy(name: 'test_bucket') do
      it { should_not have_statement_allow_all }
    end

<br>

## Matchers

This InSpec audit resource has the following special matchers. For a full list of available matchers (such as `exist`) please visit our [matchers page](https://www.inspec.io/docs/reference/matchers/).

### have_statement_allow_all (alias: has_statement_allow_all)

The `have_statement_allow_all` matcher tests if the buckets policy has a statement with the effect set to 'allow' and principal set to ' * '

    it { should_not have_statement_allow_all }
