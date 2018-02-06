---
title: About the aws_iam_group Resource
---

# aws_iam_group

Use the `aws_iam_group` InSpec audit resource to test properties of a single IAM group.

To test properties of multiple or all groups, use the `aws_iam_groups` resource.

<br>

## Syntax

An `aws_iam_group` resource block identifies a group by group name.

    # Find a group by group name
    describe aws_iam_group('mygroup') do
      it { should exist }
    end

    # Hash syntax for group name
    describe aws_iam_group(group_name: 'mygroup') do
      it { should exist }
    end

<br>

## Examples

The following examples show how to use this InSpec audit resource.

As this is the initial release of `aws_iam_group`, its limited functionality precludes examples.

<br>

## Matchers

### exists

The control will pass if a group with the given group name exists.

    describe aws_iam_group('mygroup')
      it { should exist }
    end
