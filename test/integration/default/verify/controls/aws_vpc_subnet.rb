fixtures = {}
[
  'ec2_security_group_default_vpc_id',
  'ec2_default_vpc_subnet_id',
].each do |fixture_name|
  fixtures[fixture_name] = attribute(
    fixture_name,
    default: "default.#{fixture_name}",
    description: 'See ../build/ec2.tf',
  )
end

control "aws_vpc_subnet recall of default VPC" do

  describe aws_vpc_subnet(vpc_id: fixtures['ec2_security_group_default_vpc_id'], subnet_id: fixtures['ec2_default_vpc_subnet_id']) do
    it { should exist }
  end
  describe aws_vpc_subnet(vpc_id: 'vpc-00000000', subnet_id: 'subnet-00000000') do
    it { should_not exist }
  end
end

control "aws_vpc_subnet properties of default VPC" do

  describe aws_vpc_subnet(vpc_id: fixtures['ec2_security_group_default_vpc_id'], subnet_id: fixtures['ec2_default_vpc_subnet_id']) do
    its('vpc_id') { should eq fixtures['ec2_security_group_default_vpc_id'] }
    its('subnet_id') { should eq fixtures['ec2_default_vpc_subnet_id'] }
    its('cidr_block') { should eq '172.31.96.0/20' }
  end
end
