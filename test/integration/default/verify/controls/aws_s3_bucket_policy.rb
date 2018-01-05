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

control 'aws_s3_bucket_policy exist' do
  #------------------- Exists / Permissions Owner / public files  -------------------#
  describe aws_s3_bucket_policy(bucket_name: fixtures['s3_bucket_name_public']) do
    it { should exist }
  end

  describe aws_s3_bucket_policy(bucket_name: 'NonExistentBucket') do
    it { should_not exist }
  end
end

control 'aws_s3_bucket_policy effect: deny, principal: *' do
  #------------------- Exists / Permissions Owner / public files  -------------------#
  describe aws_s3_bucket_policy(bucket_name: fixtures['s3_bucket_name_private']) do
    it { should_not have_statement_allow_all }
  end
end

control 'aws_s3_bucket_policy effect: allow, principal: *' do
  #------------------- Exists / Permissions Owner / public files  -------------------#
  describe aws_s3_bucket_policy(bucket_name: fixtures['s3_bucket_name_public']) do
    it { should have_statement_allow_all }
  end
end
