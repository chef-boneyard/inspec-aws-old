---
title: About the aws_ec2_instance Resource
---

# aws_ec2_instance

Use the `aws_ec2_instance` InSpec audit resource to test properties of a single AWS EC2 instance.

<br>

## Syntax

An `aws_ec2_instance` resource block declares a tests for a single AWS EC2 instance by name or id.

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

    describe aws_iam_user(name: 'my-instance') do
      its('image_id') { should eq 'ami-27a58d5c' }
    end

### Test that an EC2 instance has the correct tag

    describe aws_ec2_instance('i-090c29e4f4c165b74') do
      its('tags') { should include(key: 'Contact', value: 'Gilfoyle') }
    end

<br>

## Matchers

For a full list of available matchers (such as `be_running`) please visit our [matchers page](https://www.inspec.io/docs/reference/matchers/).
