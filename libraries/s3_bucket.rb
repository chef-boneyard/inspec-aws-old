# author: Christoph Hartmann

class S3Bucket < Inspec.resource(1)
  name 'aws_s3_bucket'
  desc 'Verifies settings for a S3 bucket'

  example "
    describe aws_s3_bucket('bucket-name') do
      it { should exist }
    end
  "

  def initialize(opts, conn = AWSConnection.new)
    @opts = opts
    @s3_bucket_client = conn.s3_bucket_client
    @s3_bucket_resource = conn.s3_bucket_resource
  end

  def exists?
    bucket.exists?
  end

  def name
    return @bucket_name if defined?(@bucket_name)
    @bucket_name = @opts
  end

  def to_s
    "S3 Bucket #{@name}"
  end

  private

  def bucket
    @bucket ||= @s3_bucket_resource.bucket(name)
  end
end
