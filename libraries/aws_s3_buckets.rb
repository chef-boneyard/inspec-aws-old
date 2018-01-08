# author: Matthew Dromazos
# author: Sam Cornwell

require '_aws'

class AwsS3Buckets < Inspec.resource(1)
  name 'aws_s3_buckets'
  desc 'Verifies settings for AWS S3 Buckets in bulk'
  example "
    describe aws_s3_buckets.where(availability: 'Public') do
      its('Bucket_names') { should eq [] }
      it { should_not have_public_buckets }
    end
  "
  include AwsResourceMixin
  attr_reader :table, :has_public_buckets
  alias have_public_buckets? has_public_buckets
  alias has_public_buckets? has_public_buckets

  # Underlying FilterTable implementation.
  filter = FilterTable.create
  filter.add_accessor(:where)
        .add_accessor(:entries)
        .add(:exists?) { |x| !x.entries.empty? }
        .add(:bucket_names, field: :bucket_name)
        .add(:availability, field: :availability)
  filter.connect(self, :table)

  def to_s
    'S3 Buckets'
  end

  private

  def validate_params(raw_params)
    validated_params = check_resource_param_names(
      raw_params: raw_params,
      allowed_params: [],
    )
    validated_params
  end

  def fetch_from_aws
    [
      :table,
      :has_public_buckets,
    ].each do |criterion_name|
      val = instance_variable_get("@#{criterion_name}".to_sym)
      next if val.nil?
    end
    @table  = []
    results = AwsS3Buckets::BackendFactory.create.list_buckets
    results.buckets.each do |b_info|
      bucket_availability = 'Private'
      AwsS3Buckets::BackendFactory.create.get_bucket_acl(bucket: b_info.name).grants.each do |grant|
        type = grant.grantee[:type]
        next unless type == 'Group' and grant.grantee[:uri] == 'http://acs.amazonaws.com/groups/global/AllUsers'
        @has_public_buckets = true
        bucket_availability = 'Public'
      end
      @table.push({
                    bucket_name: b_info.name,
                    creation_date: b_info.creation_date,
                    owner: {
                      display_name: results.owner.display_name,
                      id: results.owner.id,
                    },
                    availability: bucket_availability,
                  })
    end
  end

  class Backend
    class AwsClientApi < Backend
      AwsS3Buckets::BackendFactory.set_default_backend self

      def list_buckets
        AWSConnection.new.s3_client.list_buckets
      end

      def get_bucket_acl(query)
        AWSConnection.new.s3_client.get_bucket_acl(query)
      end
    end
  end
end
