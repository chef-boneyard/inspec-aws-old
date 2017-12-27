fixtures = {}
[
  's3_bucket_name',
].each do |fixture_name|
  fixtures[fixture_name] = attribute(
    fixture_name,
    default: "default.#{fixture_name}",
    description: 'See ../build/s3.tf',
  )
end

control 'aws_s3_bucket_object public file test' do
  #------------------- Exists / Permissions / public file  -------------------#
  describe aws_s3_bucket_object(name: fixtures['s3_bucket_name'], key: 'public-pic-read.jpg') do
    it { should exist }
    it { should be_public }
    its('permissions.owner') { should be_in ['FULL_CONTROL'] }
    its('permissions.authUsers') { should be_in [] }
    its('permissions.everyone') { should be_in ['READ'] }
  end
end

control 'aws_s3_bucket_object private file test' do
  #------------------- Exists / Permissions / private file  -------------------#
  describe aws_s3_bucket_object(name: fixtures['s3_bucket_name'], key: 'private-pic.jpg') do
    it { should exist }
    it { should_not be_public }
    its('permissions.owner') { should be_in ['FULL_CONTROL'] }
    its('permissions.authUsers') { should be_in [] }
    its('permissions.everyone') { should be_in [] }
  end
end
