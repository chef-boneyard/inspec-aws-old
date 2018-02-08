#======================================================#
#                    Flow Logs
#======================================================#

resource "aws_flow_log" "default_subnet" {
  log_group_name = "${aws_cloudwatch_log_group.lmf_lg_3.name}"
  iam_role_arn   = "${aws_iam_role.role_for_flow_log.arn}"
  subnet_id      = "${aws_subnet.flow_log_subnet.id}"
  traffic_type   = "ALL"
}

resource "aws_flow_log" "default_vpc" {
  log_group_name = "${aws_cloudwatch_log_group.lmf_lg_3.name}"
  iam_role_arn   = "${aws_iam_role.role_for_flow_log.arn}"
  vpc_id         = "${data.aws_vpc.flow_log_vpc.id}"
  traffic_type   = "ALL"
}

output "flow_log_default_subnet_flow_log_id" {
  value = "${aws_flow_log.default_subnet.id}"
}

output "flow_log_default_subnet_subnet_id" {
  value = "${aws_flow_log.default_subnet.subnet_id}"
}

output "flow_log_default_vpc_flow_log_id" {
  value = "${aws_flow_log.default_vpc.id}"
}

output "flow_log_default_vpc_vpc_id" {
  value = "${aws_flow_log.default_vpc.vpc_id}"
}