---
title: About the aws_iam_access_keys Resource
---

# aws_iam_access_keys

Use the `aws_iam_access_keys` InSpec audit resource to test properties of all or multiple IAM Access Keys.

To test properties of a Access Key, use the `aws_iam_access_key` resource.  You may also test properties of the access keys of a particular user using the `aws_iam_user` resource.

Access Keys are tightly coupled to the AWS User resources.  This resource is best used when you need so perform audits of all keys, or keys specified by criteria that don't relate to any particular user.  

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

This matcher causes the control to pass if the filter returned at least one result. You can negate the meaning using should_not (that is, you expect no matches).

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

A true / false value that indicates whether the Access Key is currently Active (the normal state) in the AWS console.  `inactive` is also available.

    # Check whether a particular key is enabled
    describe aws_iam_access_keys.where { active } do
      its('access_key_ids') { should include('AKIA1234567890ABCDEF')}
    end

### created_date

A DateTime, which identifies when the Access Key was created.  See also `created_days_ago` and `created_hours_ago`.

    # Don't permit creating keys on Tuesday
    describe aws_iam_access_keys.where { created_date.tuesday? } do
      it { should_not exist }
    end

### created_days_ago, created_hours_ago

An integer, representing how old the access key is.

    # Don't allow keys that are older than 90 days
    describe aws_iam_access_keys.where { created_days_ago > 90 } do
      it { should_not exist }
    end

### ever_used

A true / false value that indicates whether the Access Key has ever been used, based on the last_used_date.  `never_used` is also available.

    # Check to see if a particular key has ever been used
    describe aws_iam_access_keys.where { ever_used } do
      its('access_key_ids') { should include('AKIA1234567890ABCDEF')}
    end


### inactive

A true / false value that indicates whether the Access Key has been marked Inactive in the AWS console.  `active` is also available.

    # Don't leave inactive keys laying around
    describe aws_iam_access_keys.where { inactive } do
      it { should_not exist }
    end

### last_used_date

A DateTime, which identifies when the Access Key was last used.  If the key has never been used, this will be `nil`.  See also `ever_used`, `last_used_days_ago`, `last_used_hours_ago`, and `never_used`.

    # No one should do anything on Mondays
    describe aws_iam_access_keys.where { ever_used and last_used_date.monday? } do
      it { should_not exist }
    end

### last_used_days_ago, last_used_hours_ago

An integer, representing how long ago the key was last used.

    # Don't allow keys that sit unused for more than 90 days
    describe aws_iam_access_keys.where { last_used_days_ago > 90 } do
      it { should_not exist }
    end

### never_used

A true / false value that indicates whether the Access Key has never been used, based on the last_used_date.  `ever_used` is also available.

    # Don't allow unused keys to lay around
    describe aws_iam_access_keys.where { never_used } do
      it { should_not exist }
    end

### username

Looks for access keys owned by the named user.  Each user may have zero, one, or two access keys.

    describe aws_iam_access_keys(username: 'bob') do
      it { should exist }
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
