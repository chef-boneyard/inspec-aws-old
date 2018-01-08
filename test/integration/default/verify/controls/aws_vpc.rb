fixtures = {}
[
  'ec2_security_group_default_vpc_id',
  'vpc_non_default_id',
  'vpc_non_default_cidr_block',
  'vpc_non_default_instance_tenancy'
].each do |fixture_name|
  fixtures[fixture_name] = attribute(
    fixture_name,
    default: "default.#{fixture_name}",
    description: 'See ../build/ec2.tf',
  )
end

control "aws_vpc recall" do
  describe aws_vpc(fixtures['ec2_security_group_default_vpc_id']) do
    it { should exist}
  end

  describe aws_vpc do
    it { should exist }
  end

  describe aws_vpc(vpc_id: fixtures['vpc_non_default_id']) do
    it { should exist }
  end

  describe aws_vpc('vpc-12345678') do
    it { should_not exist }
  end
end

control "aws_vpc properties" do
  describe aws_vpc(fixtures['vpc_non_default_id']) do
    its('vpc_id') { should eq fixtures['vpc_non_default_id'] }
    its('state') { should eq 'available' }
    its('cidr_block') { should eq fixtures['vpc_non_default_cidr_block']}
    its('instance_tenancy') { should eq fixtures['vpc_non_default_instance_tenancy']}
    # TODO: figure out how to access the dhcp_options_id
  end

  describe aws_vpc do
    its('vpc_id') { should eq fixtures['ec2_security_group_default_vpc_id'] }
  end
end

control "aws_vpc matchers" do
  describe aws_vpc do
    it { should be_default }
  end

  describe aws_vpc(fixtures['ec2_security_group_default_vpc_id']) do
    it { should be_default }
  end

  describe aws_vpc(fixtures['vpc_non_default_id']) do
    it { should_not be_default }
  end
end
