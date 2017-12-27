

control 'aws_s3_buckets public buckets' do
  #------------------- Exists / Permissions Owner / public files  -------------------#
  describe aws_s3_bucket(name: fixtures['s3_bucket_name']) do
    it { should exist }
    it { should have_public_files }
    its('permissions.owner') { should be_in ['FULL_CONTROL'] }
  end
end
