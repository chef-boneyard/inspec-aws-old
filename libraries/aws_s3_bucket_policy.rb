# author: Matthew Dromazos

require '_aws'

class AwsS3BucketPolicy < Inspec.resource(1)
  name 'aws_s3_bucket_policy'
  desc 'Verifies settings for a s3 bucket'
  example "
    describe aws_s3_bucket_policy(bucket_name: 'test_bucket') do
      it { should_not have_statement_allow_all }
    end
  "

  include AwsResourceMixin
  attr_reader :bucket_name, :policy, :has_statement_allow_all
  alias have_statement_allow_all? has_statement_allow_all
  alias has_statement_allow_all? has_statement_allow_all

  def to_s
    "Bucket Policy for S3 Bucket #{@bucket_name}"
  end

  private

  def validate_params(raw_params)
    validated_params = check_resource_param_names(
      raw_params: raw_params,
      allowed_params: [:bucket_name],
      allowed_scalar_name: :bucket_name,
      allowed_scalar_type: String,
    )
    if validated_params.empty? or validated_params.key?(:bucket_name).nil?
      raise ArgumentError, 'You must provide a bucket_name to aws_s3_bucket_policy.'
    end

    validated_params
  end

  def fetch_from_aws
    [
      :bucket_name,
      :policy,
      :has_statement_allow_all,
    ].each do |criterion_name|
      val = instance_variable_get("@#{criterion_name}".to_sym)
      next if val.nil?
    end
    begin
      fetch_policy
      @exists = true
    rescue StandardError
      @exists = false
      return
    end
  end

  def fetch_policy
    @has_statement_allow_all = false
    @policy = JSON.parse(AwsS3BucketPolicy::BackendFactory.create.get_bucket_policy(bucket: bucket_name).policy.read)
    @policy['Statement'].each do |statement|
      if statement['Effect'] == 'Allow' and statement['Principal'] == '*'
        @has_statement_allow_all = true
      end
    end
  end

  # Uses the SDK API to really talk to AWS
  class Backend
    class AwsClientApi
      BackendFactory.set_default_backend(self)

      def get_bucket_policy(query)
        AWSConnection.new.s3_client.get_bucket_policy(query)
      end
    end
  end
end
