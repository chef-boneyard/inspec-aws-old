---
title: About the aws_vpc_subnet Resource
---

# aws_vpc_subnet

Use the `aws_vpc_subnet` InSpec audit resource to test properties of a vpc subnet.

To test properties of a single VPC subnet, use the `aws_vpc_subnet` resource.

To test properties of all or a group of VPC subnets, use the `aws_vpc_subnets` resource.

<br>

## Syntax

An `aws_vpc_subnet` resource block uses the parameter to select a VPC and a subnet in the VPC.

    describe aws_vpc_subnet(vpc_id: 'vpc-01234567', subnet_id: 'subnet-1234567') do
      it { should exist }
      its('cidr_block') { should eq ['10.0.1.0/24'] }
    end

<br>

## Resource Parameters

This InSpec resource accepts the following parameters, which are used to search for the VPCs subnet.

### vpc_id

A string identifying the VPC which contains zero or more subnets.

    # This will error if there is more than the default SG
    describe aws_vpc_subnet(vpc_id: 'vpc-12345678', 'subnet-1234567') do
      it { should exist }    
    end

### subnet_id

A string identifying the subnet that the VPC contains.

    # This will error if there is more than the default SG
    describe aws_vpc_subnet(vpc_id: 'vpc-12345678', subnet_id: 'subnet-12345678') do
      it { should exist }    
    end

<br>

## Properties

### cidr_block

Provides the block of ip addresses specified to the subnet.

    describe aws_vpc_subnet(vpc_id: 'vpc-12345678' , subnet_id: 'subnet-12345678') do
      its('cidr_block') { should eq '10.0.1.0/24' }    
    end

## Matchers

### exist

The `exist` matcher indicates that a subnet exists for the specified vpc.

    describe aws_vpc_subnet(vpc_id: 'vpc-1234567', subnet_id: 'subnet-12345678') do
      it { should exist }
    end
