---
title: About the aws_iam_policy Resource
---

# aws_iam_policy

Use the `aws_iam_policy` InSpec audit resource to test properties of a single managed AWS IAM Policy.

To test properties of all managed policies that are available in your AWS account, including your own customer-defined managed policies and all AWS managed policies.

A policy is an entity in AWS that, when attached to an identity or resource, defines their permissions. AWS evaluates these policies when a principal, such as a user, makes a request. Permissions in the policies determine whether the request is allowed or denied. 

Each IAM Policy is uniquely identified by its policy_name and arn.

<br>

## Syntax

An `aws_iam_policy` resource block identifies a policy by policy name.

    # Find a policy by name
    describe aws_iam_policy('AWSSupportAccess') do
      it { should exist }
    end

    # Hash syntax for ID
    describe aws_iam_policy(policy_name: 'AWSSupportAccess') do
      it { should exist }
    end

<br>

## Examples

The following examples show how to use this InSpec audit resource.

### Test that a policy does exist

    describe aws_iam_policy('AWSSupportAccess') do
      it { should exist }
    end

### Test that a policy is attached to entities

    describe aws_iam_policy('AWSSupportAccess') do
      it { should be_attached }
    end

### Test that a policy is attachable

    describe aws_iam_policy('AWSSupportAccess') do
      it { should be_attachable }
    end

<br>

## Matchers

This InSpec audit resource has the following special matchers. For a full list of available matchers (such as `exist`) please visit our [matchers page](https://www.inspec.io/docs/reference/matchers/).

### be_attached

The test will pass if the identified policy is attached to entities.

    describe aws_iam_policy('AWSSupportAccess') do
      it { should be_attached }
    end

### be_attachable

The test will pass if the identified policy is attachable.

    describe aws_iam_policy('AWSSupportAccess') do
      it { should be_attachable }
    end

## Properties

### arn

The arn value of the specified policy.

    describe aws_iam_policy('AWSSupportAccess') do
      its('arn') { should cmp "arn:aws:iam::aws:policy/AWSSupportAccess" }
    end

### default_version_id

The default_version_id value of the specified policy.

    describe aws_iam_policy('AWSSupportAccess') do
      its('default_version_id') { should cmp "v1" }
    end

### attachment_count

The count of attached entities for the specified policy.

    describe aws_iam_policy('AWSSupportAccess') do
      its('attachment_count') { should cmp 1 }
    end

### is_attachable

The is_attachable bool value of the specified policy.

    describe aws_iam_policy('AWSSupportAccess') do
      its('is_attachable') { should be true }
    end

### attached_users

The list of users attached to the specified policy.

    describe aws_iam_policy('AWSSupportAccess') do
      its('attached_users') { should include "test-user" }
    end

### attached_groups

The list of groups attached to the specified policy.

    describe aws_iam_policy('AWSSupportAccess') do
      its('attached_groups') { should include "test-group" }
    end

### attached_roles

The list of roles attached to the specified policy.

    describe aws_iam_policy('AWSSupportAccess') do
      its('attached_roles') { should include "test-role" }
    end
