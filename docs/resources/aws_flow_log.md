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
      it { should be_active }
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

### Ensure that the flow log is active

    describe aws_flow_log(flow_log_id: 'fl-12345678') do
      it { should be_active }
    end 

<br>

## Resource Parameters

This InSpec resource accepts the following parameters, which are used to search for the FLow Log.

### flow_log_id

The Flow Log ID of the Flow Log.  This is of the format `fl-` followed by 8 hexadecimal characters.  The ID is unique within your AWS account; using ID ensures that you will never match more than one Flow Log.

    # Using Hash syntax
    describe aws_flow_log(flow_log_id: 'fl-12345678') do
      it { should exist }
    end


### vpc_id

The VPC that the Flow Log is logging. This is of the format `vpc-` followed by 8 hexadecimal characters.  The vpc_id is unique within your AWS account; using vpc_id ensures that you will never match more than one Flow Log.  

    # Get the flow log for a specific vpc
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
    describe aws_flow_log(flow_log_id: 'fl-00000000')
      it { should_not exist }
    end

### have_logs_delivered_ok

Provides whether or not the logs are delivered without error.

    # Inspect the status of the delivery
    describe aws_flow_log(flow_log_id: 'fl-12345678')
      its { should have_logs_delivered_ok }
    end
    
### active

Provides whether or not the flow log is active.

    # Inspect the status of the Flow Log
    describe aws_flow_log(flow_log_id: 'fl-12345678')
      it { should be_active }
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

### flow_log_id

Provides the flow log ID.

    # Inspect that the vpc is logging to a specific Flow Log
    describe aws_flow_log(vpc_id: 'vpc-12345678')
      its('flow_log_id') { should eq 'fl-12345678' }
    end

### log_group_name

Provides the name of the Flow Log group.

    # Inspect the name of the Flow Log group
    describe aws_flow_log(flow_log_id: 'fl-12345678')
      its('log_group_name') { should eq 'lg-name' }
    end

### traffic_type

Provides the type of traffic captured for the Flow Log. (ACCEPT | REJECT | ALL)

    # Inspect the type of traffic being captures
    describe aws_flow_log(flow_log_id: 'fl-12345678')
      its('traffic_type') { should eq 'ALL' }
    end
