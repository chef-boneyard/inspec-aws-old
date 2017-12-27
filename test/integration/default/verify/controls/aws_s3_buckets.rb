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

control 'aws_s3_buckets public buckets' do
  #------------------- Exists / Permissions Owner / public files  -------------------#
  describe aws_s3_buckets do
    its('buckets') { should be_in [fixtures['s3_bucket_name']] }
    it { should have_public_buckets }
  end
end
