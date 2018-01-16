fixtures = {}
[
  's3_bucket_name_public',
].each do |fixture_name|
  fixtures[fixture_name] = attribute(
    fixture_name,
    default: "default.#{fixture_name}",
    description: 'See ../build/s3.tf',
  )
end

control 'aws_s3_bucket_object recall test' do
  #------------------- Exists / public file  -------------------#
  describe aws_s3_bucket_object(bucket_name: fixtures['s3_bucket_name_public'], key: 'public-pic-read.jpg') do
    it { should exist }
  end

  describe aws_s3_bucket_object(bucket_name: "non_existent_bucket", key: 'public-pic-read.jpg') do
    it { should_not exist }
  end

  describe aws_s3_bucket_object(bucket_name: fixtures['s3_bucket_name_public'], key: 'non_existent_object') do
    it { should_not exist }
  end

  describe aws_s3_bucket_object(bucket_name: "non_existent_bucket", key: 'non_existent_object') do
    it { should_not exist }
  end
end

control 'aws_s3_bucket_object public object properties test' do
  #------------------- Properties / public file  -------------------#
  describe aws_s3_bucket_object(bucket_name: fixtures['s3_bucket_name_public'], key: 'public-pic-read.jpg') do
    its('permissions.owner') { should be_in ['FULL_CONTROL'] }
    its('permissions.authUsers') { should be_in [] }
    its('permissions.everyone') { should be_in ['READ'] }
  end
end

control 'aws_s3_bucket_object private object properties test' do
  #------------------- Properties / private file  -------------------#
  describe aws_s3_bucket_object(bucket_name: fixtures['s3_bucket_name_public'], key: 'private-pic.jpg') do
    its('permissions.owner') { should be_in ['FULL_CONTROL'] }
    its('permissions.authUsers') { should be_in [] }
    its('permissions.everyone') { should be_in [] }
  end
end

control 'aws_s3_bucket_object public object matchers test' do
  #------------------- Properties / public file  -------------------#
  describe aws_s3_bucket_object(bucket_name: fixtures['s3_bucket_name_public'], key: 'public-pic-read.jpg') do
    it { should be_public }
  end
end

control 'aws_s3_bucket_object private object matchers test' do
  #------------------- Properties / private file  -------------------#
  describe aws_s3_bucket_object(bucket_name: fixtures['s3_bucket_name_public'], key: 'private-pic.jpg') do
    it { should_not be_public }
  end
end
