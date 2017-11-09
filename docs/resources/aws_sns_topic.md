---
title: About the aws_sns_topic Resource
---

# aws_sns_topic

Use the `aws_sns_topic` InSpec audit resource to test properties of a single AWS Simple Notification Service Topic.  SNS topics are like channels for events; some resources will place items in the SNS topic, while other resources will _subscribe_ to receive notifications when new items have appeared.

<br>

## Syntax

  # Ensure that a topic exists and has at least one subscription
  describe aws_sns_topic('arn:aws:sns:*::my-topic-name') do
    it { should exist }
    its('confirmed_subscription_count') { should_not be_zero }
  end

  # You may also use has syntax to pass the ARN
  describe aws_sns_topic(arn: 'arn:aws:sns:*::my-topic-name') do
    it { should exist }
  end
  

## Resource Parameters

### ARN

This resource expects a single parameter which should uniquely identify the SNS Topic, an ARN.  Amazon Resource Names for SNS have the format `arn:aws:sns:region:account-id:topicname`.  AWS requires you to use a fully-specified ARN when looking up an SNS topic; you cannot omit the account ID or use a wildcard region.

See also the (AWS documentation on ARNs)[http://docs.aws.amazon.com/general/latest/gr/aws-arns-and-namespaces.html].

## Matchers

### exist

Indicates that the ARN provided was found.  Use should_not to test for SNS topics that should not exist.

    # Expect good news
    describe aws_sns_topic('arn:aws:sns:*::good-news') do
      it { should exist }
    end

    # No bad news allowed
    describe aws_sns_topic('arn:aws:sns:*::bad-news') do
      it { should_not exist }
    end

## Properties

### confirmed_subscription_count

An integer indicating how many subscriptions are currently active.

    # Make sure someone is listening
    describe aws_sns_topic('arn:aws:sns:*::my-topic-name') do
      its('confirmed_subscription_count') { should_not be_zero}
    end
