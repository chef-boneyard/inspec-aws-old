class AwsS3Bucket < Inspec.resource(1)
   name 'aws_s3_bucket'
   desc 'Verifies settings for a s3 bucket'
   example "
     describe aws_s3_bucket(name: 'test_bucket') do
       it { should exist }
       it { should_not have_public_files }
       its('permissions') { should cmp ['FULL_CONTROL', 'READ'] }
     end
   "

   include AwsResourceMixin
   attr_reader :name, :permissions, :has_public_files, :policy
   alias have_public_files? has_public_files
   alias has_public_files? has_public_files

   def to_s
     "S3 Bucket #{@name}"
   end

   private

   def validate_params(raw_params)
     validated_params = check_resource_param_names(
       raw_params: raw_params,
       allowed_params: [:name],
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
       :permissions,
       :policy,
       :region,
     ].each do |criterion_name|
       val = instance_variable_get("@#{criterion_name}".to_sym)
       next if val.nil?
       filters.push(
         {
           name: criterion_name.to_s.tr('_', '-'),
           values: [val],
         },
       )
     end

     bucket_info = nil
     begin
       buckets = AwsS3Bucket::BackendFactory.create.list_buckets
       bucket_objects = AwsS3Bucket::BackendFactory.create.list_objects(bucket: name)
       @object_keys = []
       @has_public_files = false
       bucket_objects.contents.each do |object|
         grants = AwsS3Bucket::BackendFactory.create.get_object_acl(bucket: name, key: object.key)
         grants.each do |grant|
           if grant.grantee.type == 'Group' and grant.permission != ""
             @has_public_files = true
           end
         end
       end
       @permissions = AwsS3Bucket::BackendFactory.create.get_bucket_acl(bucket: name)
       # Check bucket policy
       begin
         @policy = AwsS3Bucket::BackendFactory.create.get_bucket_policy(bucket: name)
       rescue Exception
         @policy = ''
       end
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

       def list_buckets
         AWSConnection.new.s3_client.list_buckets
       end
       def list_objects(query)
         AWSConnection.new.s3_client.list_objects(query)
       end

       def get_bucket_acl(query)
         permissions = []
         AWSConnection.new.s3_client.get_bucket_acl(query).grants.each do |grant|
           permissions.push(grant.permission)
         end
         permissions
       end

       def get_object_acl(query)
         AWSConnection.new.s3_client.get_object_acl(query).grants
       end

       def get_bucket_policy(query)
         AWSConnection.new.s3_client.get_bucket_policy(query)
       end
     end
   end
 end
