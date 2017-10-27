---
title: About the aws_ec2_instance Resource
---

# aws_ec2_instance

Use the `aws_ec2_instance` InSpec audit resource to test properties of a single AWS EC2 instance.

<br>

## Syntax

An `aws_ec2_instance` resource block declares the tests for a single AWS EC2 instance by either name or id.

    describe aws_ec2_instance('i-01a2349e94458a507') do
      it { should exist }
    end

    describe aws_ec2_instance(name: 'my-instance') do
      it { should be_running }
    end

<br>

## Examples

The following examples show how to use this InSpec audit resource.

### Test that an EC2 instance does not exist

    describe aws_ec2_instance(name: 'dev-server') do
      it { should_not exist }
    end

### Test that an EC2 instance is running

    describe aws_ec2_instance(name: 'prod-database') do
      it { should be_running }
    end

### Test that an EC2 instance is using the correct image ID

    describe aws_iam_instance(name: 'my-instance') do
      its('image_id') { should eq 'ami-27a58d5c' }
    end

### Test that an EC2 instance has the correct tag

    describe aws_ec2_instance('i-090c29e4f4c165b74') do
      its('tags') { should include(key: 'Contact', value: 'Gilfoyle') }
    end

<br>

## Matchers

This InSpec audit resource has the following special matchers. For a full list of available matchers (such as `exist`) please visit our [matchers page](https://www.inspec.io/docs/reference/matchers/).

### be_pending

The `be_pending` matcher tests if the described EC2 instance state is `pending`. This indicates that an instance is provisioning. This state should be temporary.

    it { should be_pending }

### be_running

The `be_running` matcher tests if the described EC2 instance state is `running`. This indicates the instance is fully operational from AWS's perspective.

    it { should be_running }

### be_shutting_down

The `be_shutting_down` matcher tests if the described EC2 instance state is `shutting-down`. This indicates the instance has received a termination command and is in the process of being permanently halted and de-provisioned. This state should be temporary.

    it { should be_shutting_down }

### be_stopped

The `be_stopped` matcher tests if the described EC2 instance state is `stopped`. This indicates that the instance is suspended and may be started again.

    it { should be_stopped }

### be_stopping

The `be_stopping` matcher tests if the described EC2 instance state is `stopping`. This indicates that an AWS stop command has been issued, which will suspend the instance in an OS-unaware manner.  This state should be temporary.

    it { should be_stopping }

### be_terminated

The `be_terminated` matcher tests if the described EC2 instance state is `terminated`.  This indicates the instance is permanently halted and will be removed from the instance listing in a short period. This state should be temporary.

    it { should be_terminated }

### be_unknown

The `be_unknown` matcher tests if the described EC2 instance state is `unknown`. This indicates an error condition in the AWS management system. This state should be temporary.

    it { should be_unknown }
