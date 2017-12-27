class AwsS3Buckets < Inspec.resource(1)
  name 'aws_s3_buckets'
  desc 'Verifies settings for AWS S3 Buckets in bulk'
  example '
    describe aws_s3_buckets do
      it { should exist }
    end
  '

  # Underlying FilterTable implementation.
  filter = FilterTable.create
  filter.add_accessor(:where)
        .add_accessor(:entries)
        .add(:exists?) { |x| !x.entries.empty? }
  filter.connect(self, :access_key_data)

  def access_key_data
    @table
  end

  def to_s
    'S3 Buckets'
  end

  private

  def fetch_from_backend(criteria)
    @table = []
    backend = AwsS3Buckets::BackendFactory.create
    # Note: should we ever implement server-side filtering
    # (and this is a very good resource for that),
    # we will need to reformat the criteria we are sending to AWS.
    results = backend.list_buckets(criteria)
    results.buckets.each do |b_info|
      @table.push({
                    name: b_info.name,
                    creation_date: b_info.creation_date,
                    owner: {
                      display_name: results.owner.display_name,
                      id: results.owner.id,
                    },
                  })
    end
  end

  class Backend
    class AwsClientApi < Backend
      AwsS3Buckets::BackendFactory.set_default_backend self

      def list_buckets(query)
        AWSConnection.new.s3_client.list_buckets(query)
      end
    end
  end
end
