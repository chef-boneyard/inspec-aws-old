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

control 'aws_s3_bucket recall tests' do
  #------------------- Exists -------------------#
  describe aws_s3_bucket(bucket_name: fixtures['s3_bucket_name_public']) do
    it { should exist }
  end
  #------------------- Does Not Exist -------------------#
  describe aws_s3_bucket(bucket_name: 'NonExistentBucket') do
    it { should_not exist }
  end
end

control 'aws_s3_bucket properties tests' do
  #------------------- Exists / Permissions Owner / public files  -------------------#
  describe aws_s3_bucket(bucket_name: fixtures['s3_bucket_name_public']) do
    its('permissions.owner') { should be_in ['FULL_CONTROL'] }
    its('permissions.authUsers') { should be_in [] }
    its('permissions.logGroup') { should be_in [] }
    its('permissions.everyone') { should be_in ['READ'] }
    its('region') { should eq 'us-east-1' }
    its('public_objects') { should eq ["public-pic-read.jpg"] }
  end
end

control 'aws_s3_bucket matchers test' do
  describe aws_s3_bucket(bucket_name: fixtures['s3_bucket_name_public']) do
    it { should have_public_files }
    it { should be_public }
  end
end
