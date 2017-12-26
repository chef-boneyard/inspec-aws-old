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

#------------------- Exists / Permissions Owner / public files  -------------------#
describe aws_s3_bucket(name: fixtures['s3_bucket_name']) do
  it { should exist }
  it { should have_public_files }
  its('permissions_owner') { should cmp ['FULL_CONTROL'] }
end

#------------------- Permissions Log Group  -------------------#
describe aws_s3_bucket(name: fixtures['s3_bucket_name']) do
  its('permissions_log_group') { should cmp [] }
end

#------------------- Permissions Everyone  -------------------#
describe aws_s3_bucket(name: fixtures['s3_bucket_name']) do
  its('permissions_everyone') { should cmp ['READ'] }
end

#------------------- Permissions Authorized Users  -------------------#
describe aws_s3_bucket(name: fixtures['s3_bucket_name']) do
  its('permissions_auth_users') { should cmp [] }
end
