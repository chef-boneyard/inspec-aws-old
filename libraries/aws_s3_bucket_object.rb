class AwsS3BucketObject < Inspec.resource(1)
   name 'aws_s3_bucket_object'
   desc 'Verifies settings for a s3 bucket object'
   example "

   "

   include AwsResourceMixin
   attr_reader :name, :key, :id, :public, :auth_users_permissions
   alias public? public

   def to_s
     "S3 Bucket Object, Bucket Name: #{@name}, Object Key: #{@key}"
   end

   private

   def validate_params(raw_params)
     validated_params = check_resource_param_names(
       raw_params: raw_params,
       allowed_params: [:name, :key, :id],
       allowed_scalar_name: :name,
       allowed_scalar_type: String,
     )
     if validated_params.empty?
       raise ArgumentError, 'You must provide a role_name to aws_iam_role.'
     end
     validated_params
   end

   def fetch_from_aws
     # Transform into filter format expected by AWS
     filters = []
     [
       :name,
       :key,
       :id,
       :public,
       :auth_users_permissions,
     ].each do |criterion_name|
       val = instance_variable_get("@#{criterion_name}".to_sym)
       next if val.nil?
       filters.push(
         {
           name: criterion_name.to_s.tr('_', '-'),
           values: [val],
         },
       )
       # get object permissions
       grants = AwsS3BucketObject::BackendFactory.create.get_object_acl(bucket: name, key: key)
       @auth_users_permissions = []
       @public = false
       grants.each do |grant|
         if grant.grantee.type == 'Group' and grant.permission != ""
           @public = true
         end
         if grant.grantee.type == 'AmazonCustomerByEmail' and grant.permission != ''
           @auth_users_permissions.push(grant.permission)
         end
       end

     end

     begin

     rescue Aws::IAM::Errors::NoSuchEntity
       @exists = false
       return
     end
     @exists = true
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
