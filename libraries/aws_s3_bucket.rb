# author: Matthew Dromazos
class AwsS3Bucket < Inspec.resource(1)
  name 'aws_s3_bucket'
  desc 'Verifies settings for a s3 bucket'
  example "
    describe aws_s3_bucket(bucket_name: 'test_bucket') do
      it { should exist }
      it { should_not have_public_objects }
      its('permissions.owner') { should be_in ['FULL_CONTROL'] }
      its('objects.public') { should eq [] }
    end
  "

  include AwsResourceMixin
  attr_reader :bucket_name, :region 
  #attr_reader :is_public_by_acl
  #alias public? public

  def to_s
    "S3 Bucket #{@bucket_name}"
  end

  # def public_objects
  #   compute_has_public_objects if @has_public_objects.nil?
  #   @public_objects
  # end

  # def has_public_objects?
  #   compute_has_public_objects if @has_public_objects.nil?
  #   @has_public_objects
  # end
  # alias has_public_objects? has_public_objects
  # RSpec will alias has_public_objects? to have_public_objects?

  def bucket_acl
    # This is simple enough to inline it.
    @bucket_acl ||= AwsS3Bucket::BackendFactory.create.get_bucket_acl(bucket: bucket_name).grants
  end

  def bucket_policy
    @bucket_policy ||= fetch_bucket_policy
  end

  private

  def validate_params(raw_params)
    validated_params = check_resource_param_names(
      raw_params: raw_params,
      allowed_params: [:bucket_name],
      allowed_scalar_name: :bucket_name,
      allowed_scalar_type: String,
    )
    if validated_params.empty? or !validated_params.key?(:bucket_name)
      raise ArgumentError, 'You must provide a bucket_name to aws_s3_bucket.'
    end

    validated_params
  end

  def fetch_from_aws
    backend = AwsS3Bucket::BackendFactory.create

    # Since there is no basic "get_bucket" API call, use the 
    # region fetch as the existance check.
    begin
      @region = backend.get_bucket_location(bucket: bucket_name).location_constraint
    rescue Aws::S3::Errors::NoSuchBucket
      @exists = false
      return
    end
    @exists = true
  end

  def fetch_bucket_policy
    backend = AwsS3Bucket::BackendFactory.create

    begin
      # AWS SDK returns a StringIO, we have to read()
      raw_policy = backend.get_bucket_policy(bucket: bucket_name).policy
      return JSON.parse(raw_policy.read)['Statement'].map do |statement|
        lowercase_hash = {}
        statement.each_key {|k| lowercase_hash[k.downcase] = statement[k]}
        OpenStruct.new(lowercase_hash)
      end
    rescue Aws::S3::Errors::NoSuchBucketPolicy
      return []
    end
  end

  # Need to rethink this method because if there is over 1000 list_objects
  # then it will send a pagination cursor.
  def compute_has_public_objects
    @has_public_objects = false
    @public_objects = []

    AwsS3Bucket::BackendFactory.create.list_objects(bucket: bucket_name).contents.each do |object|
      grants = AwsS3Bucket::BackendFactory.create.get_object_acl(bucket: bucket_name, key: object.key).grants
      grants.each do |grant|
        if grant.grantee[:type] == 'Group' and grant.grantee[:uri] == 'http://acs.amazonaws.com/groups/global/AllUsers' and grant[:permission] != ''
          @has_public_objects = true
          @public_objects.push(object.key)
        end
      end
    end
  end

  

  # Uses the SDK API to really talk to AWS
  class Backend
    class AwsClientApi
      BackendFactory.set_default_backend(self)

      def list_objects(query)
        AWSConnection.new.s3_client.list_objects(query)
      end

      def get_bucket_acl(query)
        AWSConnection.new.s3_client.get_bucket_acl(query)
      end

      def get_object_acl(query)
        AWSConnection.new.s3_client.get_object_acl(query)
      end

      def get_bucket_location(query)
        AWSConnection.new.s3_client.get_bucket_location(query)
      end

      def get_bucket_policy(query)
        AWSConnection.new.s3_client.get_bucket_policy(query)
      end
    end
  end
end
