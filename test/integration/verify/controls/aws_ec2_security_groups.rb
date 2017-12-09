fixtures = {}
[
  'ec2_security_groups_default_vpc_id',
  'ec2_security_groups_default_group_id',
].each do |fixture_name|
  fixtures[fixture_name] = attribute(
    fixture_name,
    default: "default.#{fixture_name}",
    description: 'See ../build/ec2.tf',
  )
end

control "aws_security_groups client-side filtering" do
  all_groups = aws_ec2_security_groups

  # You should always have at least one security group
  describe all_groups do
    it { should exist }
  end

end
