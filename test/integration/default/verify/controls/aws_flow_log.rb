fixtures = {}
[
  'flow_log_default_subnet_flow_log_id',
  'flow_log_default_subnet_subnet_id',
  'flow_log_default_vpc_vpc_id',
  'flow_log_default_vpc_flow_log_id',
  'log_metric_filter_3_log_group_name',
  'role_for_flow_log_arn'
].each do |fixture_name|
  fixtures[fixture_name] = attribute(
  fixture_name,
  default: "default.#{fixture_name}",
  description: 'See ../build/vpc.tf or ../build/ec2.tf'
  )
end

control "aws_flow_log recall" do
  # recall for flow_log_id
  describe aws_flow_log(flow_log_id: fixtures['flow_log_default_subnet_flow_log_id']) do
    it { should exist }
  end

  # recall for vpc_id
  describe aws_flow_log(vpc_id: fixtures['flow_log_default_vpc_vpc_id']) do
    it { should exist }
  end

  # recall for subnet_id
  describe aws_flow_log(subnet_id: fixtures['flow_log_default_subnet_subnet_id']) do
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
  describe aws_flow_log(flow_log_id: fixtures['flow_log_default_subnet_flow_log_id']) do
    its('traffic_type') { should eq 'ALL' }
    its('deliver_logs_error_message') { should eq nil }
    its('deliver_logs_permission_arn') { should eq fixtures['role_for_flow_log_arn'] }
    its('log_group_name') { should eq fixtures['log_metric_filter_3_log_group_name'] }
    its('flow_log_id') { should eq fixtures['flow_log_default_subnet_flow_log_id'] }
  end

  # Test properties with vpc_id
  describe aws_flow_log(vpc_id: fixtures['flow_log_default_vpc_vpc_id']) do
    its('traffic_type') { should eq 'ALL' }
    its('deliver_logs_error_message') { should eq nil }
    its('deliver_logs_permission_arn') { should eq fixtures['role_for_flow_log_arn'] }
    its('log_group_name') { should eq fixtures['log_metric_filter_3_log_group_name'] }
    its('flow_log_id') { should eq fixtures['flow_log_default_vpc_flow_log_id'] }
  end

  # Test properties with subnet_id
  describe aws_flow_log(subnet_id: fixtures['flow_log_default_subnet_subnet_id']) do
    its('traffic_type') { should eq 'ALL' }
    its('deliver_logs_error_message') { should eq nil }
    its('deliver_logs_permission_arn') { should eq fixtures['role_for_flow_log_arn'] }
    its('log_group_name') { should eq fixtures['log_metric_filter_3_log_group_name'] }
    its('flow_log_id') { should eq fixtures['flow_log_default_subnet_flow_log_id'] }
  end 
end

control "aws_flow_log matchers" do
  # Test matchers with flow_log_id
  describe aws_flow_log(flow_log_id: fixtures['flow_log_default_subnet_flow_log_id']) do
    it { should be_active }
    it { should have_logs_delivered_ok }
  end

  # Test matchers with vpc_id
  describe aws_flow_log(vpc_id: fixtures['flow_log_default_vpc_vpc_id']) do
    it { should be_active }
    it { should have_logs_delivered_ok }
  end

  # Test matchers with subnet_id
  describe aws_flow_log(subnet_id: fixtures['flow_log_default_subnet_subnet_id']) do
    it { should be_active }
    it { should have_logs_delivered_ok }
  end 
end 