# Contains resources and outputs related to testing the aws_rds_* resources.

#======================================================#
#                    RDS Instances
#======================================================#


resource "aws_db_instance" "default" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.6.37"
  instance_class       = "db.t2.micro"
  identifier           = "test-instance-id"
  name                 = "test_instance"
  username             = "testuser"
  password             = "testpassword"
  parameter_group_name = "default.mysql5.6"
  skip_final_snapshot  = true
}

output "rds_db_instance_address" {
  description = "The address of the RDS instance"
  value       = "${aws_db_instance.default.address}"
}

output "rds_db_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = "${aws_db_instance.default.arn}"
}

output "rds_db_instance_availability_zone" {
  description = "The availability zone of the RDS instance"
  value       = "${aws_db_instance.default.availability_zone}"
}

output "rds_db_instance_endpoint" {
  description = "The connection endpoint"
  value       = "${aws_db_instance.default.instance_endpoint}"
}

output "rds_db_instance_hosted_zone_id" {
  description = "The canonical hosted zone ID of the DB instance (to be used in a Route 53 Alias record)"
  value       = "${aws_db_instance.default.hosted_zone_id}"
}

output "rds_db_instance_id" {
  description = "The RDS instance ID"
  value       = "${aws_db_instance.default.id}"
}

output "rds_db_instance_resource_id" {
  description = "The RDS Resource ID of this instance"
  value       = "${aws_db_instance.default.resource_id}"
}

output "rds_db_instance_status" {
  description = "The RDS instance status"
  value       = "${aws_db_instance.default.status}"
}

output "rds_db_instance_name" {
  description = "The database name"
  value       = "${aws_db_instance.default.name}"
}

output "rds_db_instance_username" {
  description = "The master username for the database"
  value       = "${aws_db_instance.default.username}"
}

output "rds_db_instance_password" {
  description = "The database password (this password may be old, because Terraform doesn't track it after initial creation)"
  value       = "${aws_db_instance.default.password}"
}

output "rds_db_instance_port" {
  description = "The database port"
  value       = "${aws_db_instance.default.port}"
}
