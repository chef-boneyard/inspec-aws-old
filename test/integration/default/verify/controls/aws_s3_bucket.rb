#------------------- Exists / Permissions / public files  -------------------#
describe aws_s3_bucket(name: '-aws_demo_s3_bucket') do
  it { should exist }
  it { should_not have_public_files }
  its('permissions') { should cmp ['FULL_CONTROL', 'READ'] }
end
