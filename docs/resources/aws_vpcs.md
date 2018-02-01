---
title: About the aws_vpcs Resource
---

# aws_vpcs

Use the `aws_vpcs` InSpec audit resource to test properties of some or all AWS Virtual Private Clouds (VPCs).

A VPC is a networking construct that provides an isolated environment.  A VPC is contained in a geographic region, but spans availability zones in that region.  Within a VPC, you may have multiple subnets, internet gateways, and other networking resources.  Computing resources such as EC2 instances reside on subnets within the VPC.

Each VPC is uniquely identified by its VPC ID.  In addition, each VPC has a non-unique CIDR IP Address range (such as 10.0.0.0/16) which it manages.

Every AWS account has at least one VPC, the "default" VPC, in every region.

<br>

## Syntax

An `aws_vpcs` resource block uses an optional filter to select a group of VPCs and then tests that group.

    # The control will pass if the filter returns at least one result. Use should_not if you expect zero matches.
    describe aws_vpcs do
      it { should exist }
    end

<br>

## Examples

The following examples show how to use this InSpec audit resource.

As this is the initial release of `aws_vpcs`, its limited functionality precludes examples.

<br>

## Matchers

### exists

The control will pass if the filter returns at least one result. Use should_not if you expect zero matches.

    # You will always have at least one VPC
    describe aws_vpcs
      it { should exist }
    end
