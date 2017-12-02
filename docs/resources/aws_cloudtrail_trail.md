---
title: About the aws_cloudtrail_trail Resource
---

# aws_cloudtrail_trail

Use the `aws_cloudtrail_trail` InSpec audit resource to test properties of a CloudTrail Trail.

CloudTrail is a service provided by AWS that logs API calls to the AWS service.  Using this data, you can audit who is attempting to make changes to your infrastructure.

Trails typically record data to an S3 bucket for long-term storage and analysis, but may also stream to a CloudWatch Log Group for realtime processing and alerting.

CloudTrail is disabled by default.  If you use the CloudTrail wizard to create a Trail, its name will be 'Default', unless you change it.

You may add multiple trails if you wish.

<br>

## Syntax

An `aws_cloudtrail_trail` resource block searches for a Trail, identified by name.  If the name is omitted, Inspec will look for a Trail named 'Default'.

    # Examine the trail created with the default name
    describe aws_cloudtrail_trail do
      it { should exist }
    end

    # Examine a trail with a custom name
    describe aws_cloudtrail_trail('my-trail') do
      it { should exist }
    end

<br>

## Examples

The following examples show how to use this InSpec audit resource.

### Ensure the default Trail is logging to the S3 bucket you specify

    describe aws_cloudtrail_trail do
      its('s3_bucket_name') { should cmp 'my-bucket'}
    end

### Determine the log_group used by the Trail named 'security'

    log_group_name = aws_cloudtrail_trail('security').log_group_name

## Matchers

This inspec resource has the following custom matchers.

### be_multi_region

Indicates if the Trail records activity taking place in more than one region.

  describe aws_cloudtrail_trail do
    it { should be_multi_region }
  end

### be_encrypted

Indicates if the Trail is being encrypted before being delivered to S3, using a KMS Key.

  describe aws_cloudtrail_trail do
    it { should be_encrypted }
  end

### have_log_file_validation_enabled

Indicates if the Trail validates the logfiles that are delivered.

  describe aws_cloudtrail_trail do
    it { should have_log_file_validation_enabled }
  end

## Properties

This Inspec resource supports the following properties:

### kms_key_id

If the Trail is being encrypted before being delivered to S3, this is the KMS Key ID.

  describe aws_cloudtrail_trail do
    its('kms_key_id') { should be '3a86879e-dead-beef-acbc-56db6b873c88' }
  end


### log_group_name

If the Trail is configured to deliver its API audit stream to CloudWatch, this is the name of the group.

  describe aws_cloudtrail_trail do
    its('log_group_name') { should cmp 'my-cloudtrail-logs' }
  end

### s3_bucket_name

The name of the S3 bucket where API logs are being delivered.

  describe aws_cloudtrail_trail do
    its('s3_bucket_name') { should cmp 'my-bucket' }
  end

 
