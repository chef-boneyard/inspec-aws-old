s3_bucket_name = attribute(
  's3_bucket_name',
  default: 'default.test-bucket.inspec-aws',
  description: 'creation of a simple bucket to test inspec exists')

describe aws_s3_bucket(s3_bucket_name) do
  it { should exist }
end
