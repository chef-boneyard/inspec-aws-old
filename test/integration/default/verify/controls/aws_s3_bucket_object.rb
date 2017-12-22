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

#------------------- Exists / Permissions / public file  -------------------#
describe aws_s3_bucket_object(name: fixtures['s3_bucket_name'], key: 'public-pic-read.jpg') do
  it { should exist }
  it { should be_public }
  its('permissions_owner') { should eq 'FULL_CONTROL' }
  its('permissions_auth_users') { should eq '' }
  its('permissions_everyone') { should eq 'READ' }
end

#------------------- Exists / Permissions / private file  -------------------#
describe aws_s3_bucket_object(name: fixtures['s3_bucket_name'], key: 'private-pic.jpg') do
  it { should exist }
  it { should_not be_public }
  its('permissions_owner') { should eq 'FULL_CONTROL' }
  its('permissions_auth_users') { should eq '' }
  its('permissions_everyone') { should eq '' }
end
