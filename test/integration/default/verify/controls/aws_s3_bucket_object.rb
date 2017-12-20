
describe aws_s3_bucket_object(name: '-aws_demo_s3_bucket', key: 'public-pic-authenticated.jpg') do
  it { should exist }
  it { should be_public }
  its('auth_users_permissions') { should cmp [] }
end
