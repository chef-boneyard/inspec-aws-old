---
title: About the aws_iam_user Resource
---

# aws_iam_user

Use the `aws_iam_user` InSpec audit resource to test properties of a single AWS IAM user.

To test properties of all or multiple users, use the `aws_iam_users` resource.

To test properties of the special AWS root user (which owns the account), use the `aws_iam_root_user` resource.

<br>

## Syntax

An `aws_iam_user` resource block declares a user by name, and then lists tests to be performed.

    describe aws_iam_user(name: 'test_user') do
      it { should exist }
    end

<br>

## Examples

The following examples show how to use this InSpec audit resource.

### Test that a user does not exist

    describe aws_iam_user(name: 'gone') do
      it { should_not exist }
    end

### Test that a user has multi-factor authentication enabled

    describe aws_iam_user(name: 'test_user') do
      it { should have_mfa_enabled }
    end

### Test that a service user does not have a password

    describe aws_iam_user(name: 'test_user') do
      it { should have_console_password }
    end

<br>

## Matchers

This InSpec audit resource has the following special matchers. For a full list of available matchers (such as `exist`) please visit our [matchers page](https://www.inspec.io/docs/reference/matchers/).

### have_console_password

The `have_console_password` matcher tests if the user has a password that could be used to log into the AWS web console.

    it { should have_console_password }

### have_mfa_enabled

The `have_mfa_enabled` matcher tests if the user has Multi-Factor Authentication enabled, requiring them to enter a secondary code when they login to the web console.

    it { should have_mfa_enabled }
