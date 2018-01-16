---
title: About the aws_vpc_subnet Resource
---

# aws_vpc_subnet

Use the `aws_vpc_subnet` InSpec audit resource to test properties of a vpc subnet.

To test properties of a single vpc subnet, use the `aws_vpc_subnet` resource.

<br>

## Syntax

An `aws_vpc_subnet` resource block uses the parameter to select a bucket and a object in the bucket

    describe aws_vpc_subnet('vpc_id') do
      it { should exist }
    end

    describe aws_vpc_subnet(vpc_id: 'vpc_id') do
      it { should exist }
    end

<br>

## Matchers

### exist

The `exist` matcher indicates that a subnet exists for the specified vpc.

    describe aws_vpc_subnet('vpc_id') do
      it { should exist }
    end
