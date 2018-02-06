---
title: About the aws_iam_users Resource
---

# aws_iam_users

Use the `aws_iam_users` InSpec audit resource to test properties of a all or multiple users.

To test properties of a single user, use the `aws_iam_user` resource.

To test properties of the special AWS root user (which owns the account), use the `aws_iam_root_user` resource.

<br>

## Syntax

An `aws_iam_users` resource block users a filter to select a group of users and then tests that group

    describe aws_iam_users.where(has_mfa_enabled?: false) do
      it { should_not exist }
    end

<br>

## Examples

The following examples show how to use this InSpec audit resource.

### Test that all users have Multi-Factor Authentication enabled

    describe aws_iam_users.where(has_mfa_enabled?: false) do
      it { should_not exist }
    end

### Test that at least one user has a console password to log into the AWS web console

    describe aws_iam_users.where(has_console_password?: true) do
      it { should exist }
    end

### Test that all users that have a console password have Multi-Factor Authentication enabled

    console_users_without_mfa = aws_iam_users
                                .where(has_console_password?: true)
                                .where(has_mfa_enabled?: false)

    describe console_users_without_mfa do
      it { should_not exist }
    end

### Test that all users that have a console password should have used it at-least once

    console_users_with_unused_password = aws_iam_users
                                         .where(has_console_password?: true)
                                         .where(password_never_used?: false)

    describe console_users_with_unused_password do
      it { should_not exist }
    end

### Test that atleast one user exists with console password and used it atleast once

    console_users_with_used_password = aws_iam_users
                                       .where(has_console_password?: true)
                                       .where(password_ever_used?: false)

    describe console_users_with_used_password do
      it { should exist }
    end


### Test that users with used passwords longer that 90 days should not exists

    describe aws_iam_users.where { password_last_used_days_ago > 90 } do
      it { should_not exist }
    end

<br>

## Matchers

This InSpec audit resource has no specific matchers.  