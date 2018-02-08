---
title: About the aws_iam_access_key Resource
---

# aws_iam_access_key

Use the `aws_iam_access_key` InSpec audit resource to test properties of a single AWS IAM access key.

<br>

## Syntax

An `aws_iam_access_key` resource block declares the tests for a single AWS IAM access key.  An access key is uniquely identified by its access key id.  

    # This is unique - the key will either exist or it won't, but it will never be an error.
    describe aws_iam_access_key(access_key_id: 'AKIA12345678ABCD') do
      it { should exist }
      it { should_not be_active }
      its('create_date') { should be > Time.now - 365 * 86400 }
      its('last_used_date') { should be > Time.now - 90 * 86400 }
    end

    # id is an alias for access_key_id
    describe aws_iam_access_key(id: 'AKIA12345678ABCD') do
      # Same
    end
    

Access keys are associated with IAM users, who may have zero, one or two access keys.  You may also lookup an access key by username.  If the user has more than one access key, an error occurs (You may use `aws_iam_access_keys` with the `username` resource parameter to access a user's keys when they have multiple keys.)

    # This is not unique.  If the user has zero or one keys, it is not an error.  
    # If they have two, it is an error.
    describe aws_iam_access_key(username: 'roderick') do
      it { should exist }
      it { should be_active }
    end

You may also use both username and access key id to ensure a particular key is associated with a particular user.

    describe aws_iam_access_key(username: 'roderick', access_key_id: 'AKIA12345678ABCD') do
      it { should exist }
    end

<br>

## Examples

The following examples show how to use this InSpec audit resource.

### Test that an IAM access key is not active

    describe aws_iam_access_key(username: 'username', id: 'access-key-id') do
      it { should_not be_active }
    end

### Test that an IAM access key is older than one year

    describe aws_iam_access_key(username: 'username', id: 'access-key-id') do
      its('create_date') { should be > Time.now - 365 * 86400 }
    end

### Test that an IAM access key has been used in the past 90 days

    describe aws_iam_access_key(username: 'username', id: 'access-key-id') do
      its('last_used_date') { should be > Time.now - 90 * 86400 }
    end

<br>

## Properties

### access_key_id

The unique ID of this access key.

    describe aws_iam_access_key(username: 'bob')
      its('access_key_id') { should cmp 'AKIA12345678ABCD' }
    end

### create_date

The date and time, as a Ruby DateTime, at which the access key was created.

    # Is the access key less than a year old?
    describe aws_iam_access_key(username: 'bob')
      its('create_date') { should be > Time.now - 365 * 86400 }
    end

### last_used_date

The date and time, as a Ruby DateTime, at which the access key was last_used.

    # Has the access key been used in the last year?
    describe aws_iam_access_key(username: 'bob')
      its('last_used_date') { should be > Time.now - 365 * 86400 }
    end

### username

The IAM user that owns this key.

    describe aws_iam_access_key(access_key_id: 'AKIA12345678ABCD')
      its('username') { should cmp 'bob' }
    end


## Matchers

This InSpec audit resource has the following special matchers. For a full list of available matchers (such as `exist`) please visit our [matchers page](https://www.inspec.io/docs/reference/matchers/).

### be_active

The `be_active` matcher tests if the described IAM access key is active.

  it { should be_active }
