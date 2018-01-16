fixtures = {}
[
  'ec2_security_group_default_vpc_id',
].each do |fixture_name|
  fixtures[fixture_name] = attribute(
    fixture_name,
    default: "default.#{fixture_name}",
    description: 'See ../build/ec2.tf',
  )
end

control "aws_vpc_subnet recall of default VPC" do

  describe aws_vpc_subnet(fixtures['ec2_security_group_default_vpc_id']) do
    it { should exist }
  end
  describe aws_vpc_subnet('no-such-vpc-id') do
    it { should_not exist }
  end
end
