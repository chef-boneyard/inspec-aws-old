---
title: About the aws_route_table Resource
---

# aws_route_table

Use the `aws_route_table` InSpec audit resource to test properties of a single Route Table. A route table contains a set of rules, called routes, that are used to determine where network traffic is directed.

<br>

## Syntax

  # Ensure that a certain route table exists by name
  describe aws_route_table('rtb-123abcde') do
    it { should exist }
  end

## Resource Parameters

### route_table_id

This resource expects a single parameter that uniquely identifes the Route Table.  You may pass it as a string, or as the value in a hash:

  describe aws_route_table('rtb-123abcde') do
    it { should exist }
  end
  # Same
  describe aws_route_table(route_table_id: 'rtb-123abcde') do
    it { should exist }
  end

## Matchers

### exist

Indicates that the Route Table provided was found.  Use should_not to test for Route Tables that should not exist.

    describe aws_route_table('should-be-there') do
      it { should exist }
    end

    describe aws_route_table('should-not-be-there') do
      it { should_not exist }
    end
