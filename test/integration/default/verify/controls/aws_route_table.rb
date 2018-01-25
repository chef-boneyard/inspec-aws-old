fixtures = {}
[
  'routetable_rtb_route_table_id',
  'routetable_rtb_associations',
  'routetable_rtb_propagating_vgws',
  'routetable_rtb_routes',
  'routetable_rtb_tags',
  'routetable_rtb_vpc_id',
].each do |fixture_name|
  fixtures[fixture_name] = attribute(
    fixture_name,
    default: "default.#{fixture_name}",
    description: 'See ../build/route_table.tf',
  )
end

control "aws_route_table recall" do
  describe aws_route_table(fixtures['routetable_rtb_route_table_id']) do
    it { should exist}
  end

  describe aws_route_table do
    it { should exist }
  end

  describe aws_route_table('rtb-2c60ec44') do
    it { should_not exist }
  end
end

control "aws_route_table properties" do
  describe aws_route_table(fixtures['routetable_rtb_route_table_id']) do
    its('vpc_id') { should eq fixtures['routetable_rtb_vpc_id'] }
    its('tags') { should eq fixtures['routetable_rtb_tags'] }
    its('routes') { should eq fixtures['routetable_rtb_routes']}
    its('propagating_vgws') { should eq fixtures['routetable_rtb_propagating_vgws']}
    its('associations') { should eq fixtures['routetable_rtb_associations']}
  end
end
