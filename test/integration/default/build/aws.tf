terraform {
  required_version = "~> 0.10.0"
}

provider "aws" {}

resource "aws_cloudwatch_log_group" "lmf_lg_1" {
  name = "${terraform.env}_lmf_lg_1"
}

# We make a separate log group to test uniqueness of LMF identifiers
resource "aws_cloudwatch_log_group" "lmf_lg_2" {
  name = "${terraform.env}_lmf_lg_2"
}

resource "aws_cloudwatch_log_metric_filter" "lmf_1" {
  name           = "${terraform.env}_lmf"
  pattern        = "testpattern01"
  log_group_name = "${aws_cloudwatch_log_group.lmf_lg_1.name}"

  metric_transformation {
    name      = "${terraform.env}_testmetric_1"
    namespace = "${terraform.env}_YourNamespace_1"
    value     = "1"
  }
}

resource "aws_cloudwatch_log_metric_filter" "lmf_2" {
  name           = "${terraform.env}_lmf"
  pattern        = "testpattern02"
  log_group_name = "${aws_cloudwatch_log_group.lmf_lg_2.name}"

  metric_transformation {
    name      = "${terraform.env}_testmetric_3"
    namespace = "${terraform.env}_YourNamespace_3"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "alarm_1" {
  alarm_name                = "${terraform.env}-test-alarm-01"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "${terraform.env}_testmetric_1"
  namespace                 = "${terraform.env}_YourNamespace_1"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "80"
  alarm_description         = "This metric is a test metric"
  insufficient_data_actions = []
}

output "cloudwatch_alarm_01" {
  value = "${terraform.env}-test-alarm-01"
}

output "lmf_1_name" {
  value = "${aws_cloudwatch_log_metric_filter.lmf_1.name}"
}

output "lmf_2_name" {
  value = "${aws_cloudwatch_log_metric_filter.lmf_2.name}"
}

output "lmf_1_metric_1_name" {
  value = "${terraform.env}_testmetric_1"
}

output "lmf_1_metric_1_namespace" {
  value = "${terraform.env}_YourNamespace_1"
}

output "lmf_lg_1_name" {
  value = "${aws_cloudwatch_log_group.lmf_lg_1.name}"
}

output "lmf_lg_2_name" {
  value = "${aws_cloudwatch_log_group.lmf_lg_2.name}"
}

#===========================================================================#
#                                   SNS
#===========================================================================#

# Test fixture: 
# sns_test_topic_01 has one confirmed subscription
# sns_test_topic_02 has no subscriptions

resource "aws_sns_topic" "sns_test_topic_01" {
  name = "${terraform.env}-test-topic-01"
}

output "sns_test_topic_01_arn" {
  value = "${aws_sns_topic.sns_test_topic_01.arn}"
}

resource "aws_sqs_queue" "sqs_test_queue_01" {
  name = "${terraform.env}-test-queue-01"
}

resource "aws_sns_topic_subscription" "sqs_test_queue_01_sub" {
  topic_arn = "${aws_sns_topic.sns_test_topic_01.arn}"
  protocol  = "sqs"
  endpoint  = "${aws_sqs_queue.sqs_test_queue_01.arn}"
}

resource "aws_sns_topic" "sns_test_topic_02" {
  name = "${terraform.env}-test-topic-02"
}

output "sns_test_topic_02_arn" {
  value = "${aws_sns_topic.sns_test_topic_02.arn}"
}