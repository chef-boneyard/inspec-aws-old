---
title: About the aws_vpc_subnet Resource
---

# aws_vpc_subnet

Use the `aws_vpc_subnet` InSpec audit resource to test properties of a vpc subnet.

To test properties of a single vpc subnet, use the `aws_vpc_subnet` resource.

<br>

## Syntax

An `aws_vpc_subnet` resource block uses the parameter to select a bucket and a object in the bucket.

    describe aws_vpc_subnet(vpc_id: 'vpc_id', subnet_id: 'subnet_id') do
      it { should exist }
      its('vpc_id') { should eq 'vpc-00000000' }
    end

<br>

## Resource Parameters

This InSpec resource accepts the following parameters, which are used to search for the vpcs subnet.

### vpc_id

A string identifying the VPC which contains the subnets.

    # This will error if there is more than the default SG
    describe aws_vpc_subnet(vpc_id: 'vpc-12345678') do
      it { should exist }    
    end

### subnet_id

A string identifying the subnet id that the vpc contains.

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

    describe aws_vpc_subnet(vpc_id: 'vpc_id', subnet_id: 'subnet-12345678') do
      it { should exist }
    end
