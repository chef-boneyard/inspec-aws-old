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
  its('permissions.owner') { should be_in ['FULL_CONTROL'] }
end

#------------------- Permissions Log Group  -------------------#
describe aws_s3_bucket(name: fixtures['s3_bucket_name']) do
  its('permissions.logGroup') { should be_in [] }
end

#------------------- Permissions Everyone  -------------------#
describe aws_s3_bucket(name: fixtures['s3_bucket_name']) do
  its('permissions.everyone') { should be_in ['READ'] }
end

#------------------- Permissions Authorized Users  -------------------#
describe aws_s3_bucket(name: fixtures['s3_bucket_name']) do
  its('permissions.authUsers') { should be_in [] }
end
