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

control "aws_vpc default vpc" do
  describe aws_vpc(fixtures['ec2_security_group_default_vpc_id']) do
    it { should exist}
    it { should be_default }
  end
end
