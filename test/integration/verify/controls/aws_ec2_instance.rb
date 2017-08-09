example_ec2_id = attribute(
  'example_ec2_id',
  default: 'default.example_ec2_id',
  description: 'ID of example ec2 instance')

example_ec2_name = attribute(
  'example_ec2_name',
  default: 'default.Example',
  description: 'Name of exapmle ec2 instance')

describe aws_ec2_instance(name: example_ec2_name) do
  it { should exist }
  its('image_id') { should eq 'ami-0d729a60' }
  its('instance_type') { should eq 't2.micro' }
end

describe aws_ec2_instance(example_ec2_id) do
  it { should exist }
  its('image_id') { should eq 'ami-0d729a60' }
  its('instance_type') { should eq 't2.micro' }
end

# must use a real EC2 instance name, as the SDK will first check to see if it's well formed before sending requests
>>>>>>> Rename EC2-instance resources:test/integration/verify/controls/aws_ec2_instance.rb
describe aws_ec2_instance('i-06b4bc106e0d03dfd') do
  it { should_not exist }
end
