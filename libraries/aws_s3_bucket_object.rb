# author: Matthew Dromazos

require '_aws'

class AwsS3BucketObject < Inspec.resource(1)
  name 'aws_s3_bucket_object'
  desc 'Verifies settings for a s3 bucket object'
  example "
    describe aws_s3_bucket_object(bucket_name: 'bucket_name', key: 'file_name') do
      it { should exist }
      its('permissions.authUsers') { should be_in [] }
      its('permissions.owner') { should be_in ['FULL_CONTROL'] }
      its('permissions.everyone') { should be_in [] }
    end
  "

  include AwsResourceMixin
  attr_reader :bucket_name, :key, :id, :public, :permissions
  alias public? public

  def to_s
    "s3://#{@bucket_name}/#{@key}"
  end

  private

  def validate_params(raw_params)
    validated_params = check_resource_param_names(
      raw_params: raw_params,
      allowed_params: [:bucket_name, :key, :id],
      allowed_scalar_name: [:bucket_name],
      allowed_scalar_type: String,
    )
    if validated_params.empty? or !validated_params.key?(:bucket_name) or !validated_params.key?(:key)
      raise ArgumentError, 'You must provide a bucket_name and key to aws_s3_bucket_object.'
    end
    validated_params
  end

  def fetch_from_aws
    [
      :bucket_name,
      :key,
      :id,
      :public,
      :permissions,
    ].each do |criterion_name|
      val = instance_variable_get("@#{criterion_name}".to_sym)
      next if val.nil?
    end
    begin
      fetch_permissions
      @exists = true
    rescue StandardError
      @exists = false
      return
    end
  end

  # get the permissions of an objectg
  def fetch_permissions
    # Use a Mash to make it easier to access hash elements in "its('permissions') {should ...}"
    @permissions = Hashie::Mash.new({})
    %w{
      owner authUsers everyone
    }.each { |perm| @permissions[perm] ||= [] }

    @public = false
    AwsS3BucketObject::BackendFactory.create.get_object_acl(bucket: bucket_name, key: key).each do |grant|
      permission = grant[:permission]
      type       = grant.grantee[:type]
      uri        = grant.grantee[:uri]
      if type == 'Group' and uri == 'http://acs.amazonaws.com/groups/global/AllUsers'
        @public = true
        @permissions[:everyone].push(permission)
      elsif type == 'AmazonCustomerByEmail'
        @permissions[:authUsers].push(permission)
      elsif type == 'CanonicalUser'
        @permissions[:owner].push(permission)
      end
    end
  end

  # Uses the SDK API to really talk to AWS
  class Backend
    class AwsClientApi
      BackendFactory.set_default_backend(self)
      def get_object_acl(query)
        AWSConnection.new.s3_client.get_object_acl(query).grants
      end
    end
  end
end
