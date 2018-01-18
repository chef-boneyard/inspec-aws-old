fixtures = {}
[
  'kms_key_disabled_arn',  
  'kms_key_enabled_arn',
  'kms_key_recall_hit_arn',
  'kms_key_enabled_key_id',
  'kms_key_enabled_key_description'
].each do |fixture_name|
  fixtures[fixture_name] = attribute(
  fixture_name,
  default: "default.#{fixture_name}",
  description: 'See ../build/kms.tf',
  )
end

control "aws_kms_key recall" do
  describe aws_kms_key(fixtures['kms_key_recall_hit_arn']) do
    it { should exist}
  end
  describe aws_kms_key(key_arn: fixtures['kms_key_recall_hit_arn']) do
    it { should exist }
  end
  describe aws_kms_key('non-existant-key') do
    it { should_not exist }
  end
end

control "aws_kms_key properties" do
  describe aws_kms_key(fixtures['kms_key_enabled_arn']) do
    its('key_id') { should eq fixtures['kms_key_enabled_key_id'] }
    its('description') { should eq fixtures['kms_key_enabled_key_description'] }
    its('created_days_ago') { should eq 0 }
    its('key_usage') { should eq 'ENCRYPT_DECRYPT' }
    its('key_state') { should eq 'Enabled' }
    its('origin') { should eq 'AWS_KMS' }
    its('key_manager') { should eq 'CUSTOMER' }
  end
end

control "aws_kms_key matchers" do
  describe aws_kms_key(fixtures['kms_key_enabled_arn']) do
    it { should be_enabled }
  end
  describe aws_kms_key(fixtures['kms_key_enabled_arn']) do
    it { should be_rotation_enabled }
  end
  describe aws_kms_key(fixtures['kms_key_disabled_arn']) do
    it { should_not be_rotation_enabled }
  end
end