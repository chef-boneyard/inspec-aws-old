terraform {
  required_version = "~> 0.10.0"
}

provider "aws" {}



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