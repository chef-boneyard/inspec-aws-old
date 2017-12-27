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
control 'aws_s3_bucket_policy effect: allow, principal: *' do
  #------------------- Exists / Permissions Owner / public files  -------------------#
  describe aws_s3_bucket_policy(name: fixtures['s3_bucket_name']) do
    it { should exist }
    it { should_not have_statement_allow_all }
  end
end
