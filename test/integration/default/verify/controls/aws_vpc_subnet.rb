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

  describe aws_vpc_subnet(vpc_id: fixtures['ec2_security_group_default_vpc_id'], subnet_id: 'subnet-00000000') do
    it { should_not exist }
  end

  describe aws_vpc_subnet(vpc_id: 'vpc-00000000', subnet_id: fixtures['ec2_default_vpc_subnet_id']) do
    it { should_not exist }
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
    its('available_ip_address_count') { should eq 4091 }
    its('map_public_ip_on_launch') { should eq false }
    its('default_for_az') { should eq false }
    its('availability_zone') { should eq 'us-east-1c' }
    its('state') { should eq 'available' }
    its('ipv_6_cidr_block_association_set') { should eq [] }
    its('assign_ipv_6_address_on_creation') { should eq false }
  end
end
