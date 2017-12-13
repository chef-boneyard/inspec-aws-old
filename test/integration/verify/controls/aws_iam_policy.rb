describe aws_iam_policy(arn: 'arn:aws:iam::aws:policy/AWSSupportAccess') do 
	it { should exist }
	its('attachment_count') { should be > 0 }
	its('name') {should eq 'AWSSupportAccess'}
end
describe aws_iam_policy(arn: 'arn:aws:iam::aws:policy/AWSSupportAccesses') do 
	it{ should_not exist }
end
