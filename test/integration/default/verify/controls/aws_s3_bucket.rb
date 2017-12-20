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

#------------------- Exists / Permissions / public files  -------------------#
describe aws_s3_bucket(name: fixtures['s3_bucket_name']) do
  it { should exist }
  it { should have_public_files }
  its('permissions') { should cmp ['FULL_CONTROL', 'READ'] }
end
