

control 'aws_s3_buckets public buckets' do
  #------------------- Exists / Permissions Owner / public files  -------------------#
  describe aws_s3_bucket do
    it { should exist }
  end
end
