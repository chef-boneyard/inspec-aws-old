---
title: About the aws_iam_policys Resource
---

# aws_iam_policys

Use the `aws_iam_policys` InSpec audit resource to test properties of some or all AWS IAM Policys.

To test properties of all managed policies that are available in your AWS account, including your own customer-defined managed policies and all AWS managed policies.

A policy is an entity in AWS that, when attached to an identity or resource, defines their permissions. AWS evaluates these policies when a principal, such as a user, makes a request. Permissions in the policies determine whether the request is allowed or denied.

Each IAM Policy is uniquely identified by either its policy_name or arn.

<br>

## Syntax

An `aws_iam_policys` resource block collects a group of IAM Policys and then tests that group.

    # Verify the policy specified by the policy name is included in IAM Policys in the AWS account.
    describe aws_iam_policys do
      its('policy_names') { should include('test-policy-1') }
    end

<br>

## Examples

The following examples show how to use this InSpec audit resource.

As this is the initial release of `aws_iam_policys`, its limited functionality precludes examples.

<br>

## Matchers

### exists

The control will pass if the filter returns at least one result. Use should_not if you expect zero matches.

    # Verify that at least one IAM Policys exists.
    describe aws_iam_policys
      it { should exist }
    end   

## Properties

### policy_names

Provides a list of policy names for all IAM Policys in the AWS account.

    describe aws_iam_policys do
      its('policy_names') { should include('test-policy-1') }
    end

### arns

Provides a list of policy arns for all IAM Policys in the AWS account.

    describe aws_iam_policys do
      its('arns') { should include('arn:aws:iam::aws:policy/test-policy-1') }
    end

### entries

Provides access to the raw results of the query.  This can be useful for checking counts and other advanced operations.

    # Allow at most 100 IAM Policys on the account
    describe aws_iam_policys do
      its('entries.count') { should be <= 100}
    end
