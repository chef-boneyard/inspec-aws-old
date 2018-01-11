---
title: About the aws_rds_instance Resource
---

# aws_rds_instance

Use the `aws_rds_instance` InSpec audit resource to test detailed properties of an individual RDS.

RDS gives you access to the capabilities of a MySQL, MariaDB, PostgreSQL, Microsoft SQL Server, Oracle, or Amazon Aurora database server.

<br>

## Syntax

An `aws_rds_instance` resource block uses resource parameters to search for a RDS, and then tests that RDS.  If no RDSs match, no error is raised, but the `exists` matcher will return `false` and all properties will be `nil`.  If more than one RDS matches (due to vague search parameters), an error is raised.

    # Ensure you have a RDS with a certain ID
    # This is "safe" - RDS IDs are unique within an account
    describe aws_rds_instance('test-instance-id') do
      it { should exist }
    end

    # Ensure you have a RDS with a certain ID
    # This uses hash syntax
    describe aws_rds_instance(db_instance_identifier: 'test-instance-id') do
      it { should exist }
    end

<br>

## Examples

The following examples show how to use this InSpec audit resource.

As this is the initial release of `aws_rds_instance`, its limited functionality precludes examples.

<br>

## Resource Parameters

This InSpec resource accepts the following parameters, which are used to search for the RDS.

### exists

The control will pass if the specified RDS was found.  Use should_not if you want to verify that the specified RDS does not exist.

    # Using Hash syntax 
    describe aws_rds_instance(db_instance_identifier: 'test-instance-id') do
      it { should exist }
    end
    
    # Using the instance id directly from the terraform file
    describe aws_rds_instance(fixtures['rds_db_instance_id']) do
      it { should exist }
    end 

    # Make sure we don't have any RDSs with the name 'nogood'
    describe aws_rds_instance('nogood') do
      it { should_not exist }
    end

## Properties
