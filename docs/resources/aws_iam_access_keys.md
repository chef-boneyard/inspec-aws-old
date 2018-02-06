---
title: About the aws_iam_access_keys Resource
---

# aws_iam_access_keys

Use the `aws_iam_access_keys` InSpec audit resource to test properties of some or all IAM Access Keys.

To test properties of a single Access Key, use the `aws_iam_access_key` resource instead.  
To test properties of an individual user's access keys, use the `aws_iam_user` resource.

Access Keys are closely related to AWS User resources.  Use this resource to perform audits of all keys or of keys specified by criteria unrelated to any particular user.  

<br>

## Syntax

An `aws_iam_access_keys` resource block uses an optional filter to select a group of access keys and then tests that group.

    # Do not allow any access keys
    describe aws_iam_access_keys do
      it { should_not exist }
    end

    # Don't let fred have access keys, using filter argument syntax
    describe aws_iam_access_keys.where(username: 'fred') do
      it { should_not exist }
    end  

    # Don't let fred have access keys, using filter block syntax (most flexible)
    describe aws_iam_access_keys.where { username == 'fred' } do
      it { should_not exist }
    end    

<br>

## Examples

The following examples show how to use this InSpec audit resource.

### Disallow access keys created more than 90 days ago

    describe aws_iam_access_keys.where { created_age > 90 } do
      it { should_not exist }
    end 

<br>

## Matchers

### exists

The control will pass if the filter returns at least one result. Use should_not if you expect zero matches.

    # Sally should have at least one access key
    describe aws_iam_access_keys.where(username: 'sally') do
      it { should exist }
    end

    # Don't let fred have access keys
    describe aws_iam_access_keys.where(username: 'fred') do
      it { should_not exist }
    end   

## Filter Criteria

### active

A true / false value indicating if an Access Key is currently "Active" (the normal state) in the AWS console.  See also: `inactive`.

    # Check whether a particular key is enabled
    describe aws_iam_access_keys.where { active } do
      its('access_key_ids') { should include('AKIA1234567890ABCDEF')}
    end

### create_date

A DateTime identifying when the Access Key was created.  See also `created_days_ago` and `created_hours_ago`.

    # Detect keys older than 2017
    describe aws_iam_access_keys.where { create_date < DateTime.parse('2017-01-01') } do
      it { should_not exist }
    end

### created_days_ago, created_hours_ago

An integer, representing how old the access key is.

    # Don't allow keys that are older than 90 days
    describe aws_iam_access_keys.where { created_days_ago > 90 } do
      it { should_not exist }
    end

### created_with_user

A true / false value indicating if the Access Key was likely created at the same time as the user, by checking if the difference between created_date and user_created_date is less than 1 hour.

    # Do not automatically create keys for users
    describe aws_iam_access_keys.where { created_with_user } do
      it { should_not exist }
    end

### ever_used

A true / false value indicating if the Access Key has ever been used, based on the last_used_date. See also: `never_used`.

    # Check to see if a particular key has ever been used
    describe aws_iam_access_keys.where { ever_used } do
      its('access_key_ids') { should include('AKIA1234567890ABCDEF')}
    end


### inactive

A true / false value indicating if the Access Key has been marked Inactive in the AWS console. See also: `active`.

    # Don't leave inactive keys laying around
    describe aws_iam_access_keys.where { inactive } do
      it { should_not exist }
    end

### last_used_date

A DateTime identifying when the Access Key was last used. Returns nil if the key has never been used. See also: `ever_used`, `last_used_days_ago`, `last_used_hours_ago`, and `never_used`.

    # No one should do anything on Mondays
    describe aws_iam_access_keys.where { ever_used and last_used_date.monday? } do
      it { should_not exist }
    end

### last_used_days_ago, last_used_hours_ago

An integer representing when the key was last used. See also: `ever_used`, `last_used_date`, and `never_used`.

    # Don't allow keys that sit unused for more than 90 days
    describe aws_iam_access_keys.where { last_used_days_ago > 90 } do
      it { should_not exist }
    end

### never_used

A true / false value indicating if the Access Key has never been used, based on the last_used_date. See also: `ever_used`.

    # Don't allow unused keys to lay around
    describe aws_iam_access_keys.where { never_used } do
      it { should_not exist }
    end

### username

Searches for access keys owned by the named user. Each user may have zero, one, or two access keys.

    describe aws_iam_access_keys(username: 'bob') do
      it { should exist }
    end

### user_created_date

The date at which the user was created.

    # Users have to be a week old to have a key
    describe aws_iam_access_keys.where { user_created_date > Date.now - 7 }
      it { should_not exist }
    end

## Properties

### access_key_ids

Provides a list of all access key IDs matched.

    describe aws_iam_access_keys do
      its('access_key_ids') { should include('AKIA1234567890ABCDEF') }
    end

### entries

Provides access to the raw results of the query.  This can be useful for checking counts and other advanced operations.

    # Allow at most 100 access keys on the account
    describe aws_iam_access_keys do
      its('entries.count') { should be <= 100}
    end
