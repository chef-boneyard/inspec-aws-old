---
title: About the aws_iam_groups Resource
---

# aws_iam_groups

Use the `aws_iam_groups` InSpec audit resource to test properties of all or multiple groups.

To test properties of a single group, use the `aws_iam_group` resource.

<br>

## Syntax

An `aws_iam_groups` resource block uses an optional filter to select a collection of IAM groups and then tests that collection.

    # The control will pass if the filter returns at least one result. Use should_not if you expect zero matches.
    describe aws_iam_groups do
      it { should exist }
    end

<br>

## Examples

The following examples show how to use this InSpec audit resource.

As this is the initial release of `aws_iam_groups`, its limited functionality precludes examples.

<br>

## Matchers

### exists

The control will pass if the filter returns at least one result. Use should_not if you expect zero matches.

    describe aws_iam_groups
      it { should exist }
    end
