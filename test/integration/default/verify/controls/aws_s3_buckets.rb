fixtures = {}
[
  's3_bucket_name_public',
  's3_bucket_name_private',
].each do |fixture_name|
  fixtures[fixture_name] = attribute(
    fixture_name,
    default: "default.#{fixture_name}",
    description: 'See ../build/s3.tf',
  )
end

control 'aws_s3_buckets recall tests' do
  describe aws_s3_buckets.where(bucket_name: fixtures['s3_bucket_name_public']) do
    it { should exist }
  end

  describe aws_s3_buckets.where(bucket_name: fixtures['s3_bucket_name_private']) do
    it { should exist }
  end

  describe aws_s3_buckets.where(bucket_name: 'NonExistentBucket') do
    it { should_not exist }
  end

  describe aws_s3_buckets do
    its('bucket_names') { should eq ["aws-demo-s3-bucket-private-test.chef.io", "aws-demo-s3-bucket-public-test.chef.io"] }
  end
end

control 'aws_s3_buckets properties test' do
  describe aws_s3_buckets.where(availability: 'Public') do
    its('bucket_names') { should eq ["aws-demo-s3-bucket-public-test.chef.io"] }
  end

  describe aws_s3_buckets.where(availability: 'Private') do
    its('bucket_names') { should eq ["aws-demo-s3-bucket-private-test.chef.io"] }
  end
end

control 'aws_s3_buckets matchers test' do
  describe aws_s3_buckets do
    it { should have_public_buckets }
  end
end
