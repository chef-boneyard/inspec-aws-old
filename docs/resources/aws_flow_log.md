---
title: About the aws_flow_log Resource
---

# aws_flow_log

Use the `aws_flow_log` InSpec audit resource to test detailed properties of an individual Flow Log.

<br>

## Syntax

An `aws_flow_log` resource block uses resource parameters to search for a Flow Log, and then tests that Flow Log.  If no Flow Logs match, no error is raised, but the `exists` matcher will return `false` and all properties will be `nil`.

    # Ensure the flow log is active
    describe aws_flow_log(flow_log_id: 'fl-12345678') do
      its('flow_log_status') { should eq 'ACTIVE' }
    end

    describe aws_flow_log(vpc_id: 'fl-12345678') do
      it { should exist }
    end

    describe aws_flow_log(subnet_id: 'fl-12345678') do
      it { should exist }
    end

<br>

## Examples

The following examples show how to use this InSpec audit resource.

As this is the initial release of `aws_flow_log`, its limited functionality precludes examples.

<br>

## Resource Parameters

This InSpec resource accepts the following parameters, which are used to search for the Security Group.

### flow_log_id

The Flow Log ID of the Flow Log.  This is of the format `fl-` followed by 8 hexadecimal characters.  The ID is unique within your AWS account; using ID ensures that you will never match more than one Flow Log.

    # Using Hash syntax
    describe aws_flow_log(flow_log_id: 'fl-12345678') do
      it { should exist }
    end


### vpc_id

The VPC that the Flow Log is logging. This is of the format `vpc-` followed by 8 hexadecimal characters.  The vpc_id is unique within your AWS account; using vpc_id ensures that you will never match more than one Flow Log.  

    # Get default security group for a certain VPC
    describe aws_flow_log(vpc_id: 'vpc-12345678') do
      it { should exist }
    end

### subnet_id

The Subnet that the Flow Log is logging. This is of the format `subnet-` followed by 8 hexadecimal characters.  The subnet_id is unique within your AWS account; using subnet_id ensures that you will never match more than one Flow Log.  

    # This will error if there is more than the default SG
    describe aws_flow_log(subnet_id: 'subnet-12345678') do
      it { should exist }    
    end

<br>

## Matchers

### exists

The control will pass if the specified Flow Log was found.  Use should_not if you want to verify that the specified Flow Log does not exist.

    # Test to see that a specific Flow Log exists
    describe aws_flow_log(flow_log_id: 'fl-12345678')
      it { should exist }
    end   

    # Test to make sure a specific Flow Log does not exist
    describe aws_ec2_security_group(flow_log_id: 'fl-00000000')
      it { should_not exist }
    end

## Properties

### deliver_logs_error_message

Provides information about the error that occurred.

    # Inspect the delivery logs error message
    describe aws_flow_log(flow_log_id: 'fl-12345678')
      its('deliver_logs_error_message') { should eq 'Access error' }
    end

### deliver_logs_permission_arn

Provides the ARN of the IAM role that posts logs to CloudWatch Logs.

    # Inspect permission arn
    describe aws_flow_log(flow_log_id: 'fl-12345678')
      its('deliver_logs_permission_arn') { should eq 'arn:aws:iam::721741954427:role/test.role_for_ec2_with_role' }
    end

### deliver_logs_status

Provides the status of the logs delivery (SUCCESS | FAILED).

    # Inspect the status of the delivery
    describe aws_flow_log(flow_log_id: 'fl-12345678')
      its('deliver_logs_status') { should eq 'SUCCESS' }
    end

### flow_log_id

Provides the flow log ID.

    # Inspect that the vpc is logging to a specific Flow Log
    describe aws_flow_log(vpc_id: 'vpc-12345678')
      its('flow_log_id') { should eq 'fl-12345678' }
    end

### flow_log_status

Provides the status of the Flow Log.

    # Inspect the status of the Flow Log
    describe aws_flow_log(flow_log_id: 'fl-12345678')
      its('flow_log_status') { should eq 'ACTIVE' }
    end

### log_group_name

Provides the name of the Flow Log group.

    # Inspect the name of the Flow Log group
    describe aws_flow_log(flow_log_id: 'fl-12345678')
      its('log_group_name') { should eq 'lg-name' }
    end

### resource_id

Provides the ID of the resource on which the Flow Log was created.

    # Inspect the ID of the resource the Flow Log is logging
    describe aws_flow_log(flow_log_id: 'fl-12345678')
      its('resourc_id') { should eq 'vpc-12345678' }
    end

### traffic_type

Provides the type of traffic captured for the Flow Log.

    # Inspect the type of traffic being captures
    describe aws_flow_log(flow_log_id: 'fl-12345678')
      its('traffic_type') { should eq 'ALL' }
    end
