# author: Matthew Dromazos

require '_aws'

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
  attr_reader :bucket_name, :permissions, :region, :public
  alias public? public

  def to_s
    "S3 Bucket #{@bucket_name}"
  end

  def public_objects
    compute_has_public_objects unless !@has_public_objects.nil?
    @public_objects
  end

  def has_public_objects
    compute_has_public_objects unless !@has_public_objects.nil?
    @has_public_objects
  end
  alias have_public_objects? has_public_objects
  alias has_public_objects? has_public_objects

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
    [
      :bucket_name,
      :permissions,
      :region,
      :public,
    ].each do |criterion_name|
      val = instance_variable_get("@#{criterion_name}".to_sym)
      next if val.nil?
    end

    begin
      fetch_permissions
      fetch_region
    rescue StandardError
      @exists = false
      return
    end
    @exists = true
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

  def fetch_permissions
    # Use a Mash to make it easier to access hash elements in "its('permissions') {should ...}"
    @permissions = Hashie::Mash.new({})
    @public = false
    # Make sure standard extensions exist so we don't get nil for nil:NilClass
    # when the user tests for extensions which aren't present
    %w{
      owner logGroup authUsers everyone
    }.each { |perm| @permissions[perm] ||= [] }

    AwsS3Bucket::BackendFactory.create.get_bucket_acl(bucket: bucket_name).grants.each do |grant|
      type = grant.grantee[:type]
      permission = grant[:permission]
      uri = grant.grantee[:uri]
      if type == 'CanonicalUser'
        @permissions[:owner].push(permission)
      elsif type == 'AmazonCustomerByEmail'
        @permissions[:authUsers].push(permission)
      elsif type == 'Group' and uri =~ /AllUsers/
        @permissions[:everyone].push(permission)
        @public = true
      elsif type == 'Group' and uri =~ /LogDelivery/
        @permissions[:logGroup].push(permission)
      end
    end
  end

  def fetch_region
    @region = AwsS3Bucket::BackendFactory.create.get_bucket_location(bucket: bucket_name).location_constraint
    @region = 'us-east-1' unless @region != ''
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
    end
  end
end
