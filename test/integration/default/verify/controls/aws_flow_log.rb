iam_fixtures = {}
[
  'flow_log_default_subnet_id',
  'flow_log_default_vpc_id',
  'log_metric_filter_1_log_group_name'
].each do |fixture_name|
  iam_fixtures[fixture_name] = attribute(
  fixture_name,
  default: "default.#{fixture_name}",
  description: 'See ../build/iam.tf',
  )
end

ec2_fixtures = {}
[
  'ec2_security_group_default_vpc_id',
  'ec2_default_vpc_subnet_id',
  'role_for_ec2_with_role_arn'
].each do |fixture_name|
  ec2_fixtures[fixture_name] = attribute(
  fixture_name,
  default: "default.#{fixture_name}",
  description: 'See ../build/iam.tf',
  )
end

control "aws_flow_log recall" do
  describe aws_flow_log(flow_log_id: iam_fixtures['flow_log_default_subnet_id']) do
    it { should exist}
  end

  # recall for flow_log_id
  describe aws_flow_log(flow_log_id: iam_fixtures['flow_log_default_subnet_id']) do
    it { should exist }
  end

  # recall for vpc_id
  describe aws_flow_log(vpc_id: ec2_fixtures['ec2_security_group_default_vpc_id']) do
    it { should exist }
  end

  # recall for subnet_id
  describe aws_flow_log(subnet_id: ec2_fixtures['ec2_default_vpc_subnet_id']) do
    it { should exist }
  end

  describe aws_flow_log(flow_log_id: 'fl-00000000') do
    it { should_not exist }
  end

  describe aws_flow_log(vpc_id: 'vpc-00000000') do
    it { should_not exist }
  end

  describe aws_flow_log(subnet_id: 'subnet-00000000') do
    it { should_not exist }
  end
end

control "aws_flow_log properties" do
  # Test properties with just flow_log_id
  describe aws_flow_log(flow_log_id: iam_fixtures['flow_log_default_vpc_id']) do
    its('flow_log_status') { should eq 'ACTIVE' }
    its('traffic_type') { should eq 'ALL' }
    its('deliver_logs_error_message') { should eq nil }
    its('deliver_logs_permission_arn') { should eq ec2_fixtures['role_for_ec2_with_role_arn'] }
    its('log_group_name') { should eq iam_fixtures['log_metric_filter_1_log_group_name'] }
    its('flow_log_id') { should eq iam_fixtures['flow_log_default_vpc_id'] }
    its('deliver_logs_status') { should eq nil }
  end

  # Test properties vpc_id
  describe aws_flow_log(vpc_id: ec2_fixtures['ec2_security_group_default_vpc_id']) do
    its('flow_log_status') { should eq 'ACTIVE' }
    its('traffic_type') { should eq 'ALL' }
    its('deliver_logs_error_message') { should eq nil }
    its('deliver_logs_permission_arn') { should eq ec2_fixtures['role_for_ec2_with_role_arn'] }
    its('log_group_name') { should eq iam_fixtures['log_metric_filter_1_log_group_name'] }
    its('flow_log_id') { should eq iam_fixtures['flow_log_default_vpc_id'] }
    its('deliver_logs_status') { should eq nil }
    its('resource_id') { should eq ec2_fixtures['ec2_security_group_default_vpc_id'] }
  end

  # Test properties with subnet_id
  describe aws_flow_log(subnet_id: ec2_fixtures['ec2_default_vpc_subnet_id']) do
    its('flow_log_status') { should eq 'ACTIVE' }
    its('traffic_type') { should eq 'ALL' }
    its('deliver_logs_error_message') { should eq nil }
    its('deliver_logs_permission_arn') { should eq ec2_fixtures['role_for_ec2_with_role_arn'] }
    its('log_group_name') { should eq iam_fixtures['log_metric_filter_1_log_group_name'] }
    its('flow_log_id') { should eq iam_fixtures['flow_log_default_subnet_id'] }
    its('deliver_logs_status') { should eq nil }
    its('resource_id') { should eq ec2_fixtures['ec2_default_vpc_subnet_id'] }
  end
end