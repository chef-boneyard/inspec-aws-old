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

control "aws_vpc_subnets client side filtering" do
  all_subnets = aws_vpc_subnets


  # You should be able to get a specific subnet given its id
  describe all_subnets.where(subnet_id: fixtures['ec2_default_vpc_subnet_id']) do
    it { should exist }
  end

  describe all_subnets.where(vpc_id: 'vpc-00000000') do
    it { should_not exist }
  end
end

control "aws_vpc_subnets properties of default VPC" do
  # you should be able to test the cidr_block of a subnet
  describe aws_vpc_subnets.where(subnet_id: fixtures['ec2_default_vpc_subnet_id']) do
    its('cidr_blocks') { should eq ['172.31.96.0/20'] }
  end
end
