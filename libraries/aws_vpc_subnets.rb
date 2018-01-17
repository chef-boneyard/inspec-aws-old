class AwsVpcSubnets < Inspec.resource(1)
  name 'aws_vpc_subnets'
  desc ''
  example "

  "

  # Constructor.  Args are reserved for row fetch filtering.
  def initialize(raw_criteria = {})
    validated_criteria = validate_filter_criteria(raw_criteria)
    fetch_from_backend(validated_criteria)
  end

  # Underlying FilterTable implementation.
  filter = FilterTable.create
  filter.add_accessor(:where)
        .add_accessor(:entries)
        .add(:exists?) { |x| !x.entries.empty? }
        .add(:vpc_ids, field: :vpc_id)
        .add(:subnet_ids, field: :subnet_id)
        .add(:cidr_blocks, field: :cidr_block)
  filter.connect(self, :access_key_data)

  def access_key_data
    @table
  end

  def to_s
    'EC2 VPC Subnets'
  end

  private

  def validate_filter_criteria(raw_criteria)
    unless raw_criteria.is_a? Hash
      raise 'Unrecognized criteria for fetching Vpc Subnets. ' \
            "Use 'criteria: value' format."
    end

    # No criteria yet
    recognized_criteria = check_criteria_names(raw_criteria)
    recognized_criteria
  end

  def check_criteria_names(raw_criteria: {}, allowed_criteria: [])
    # Remove all expected criteria from the raw criteria hash
    recognized_criteria = {}
    allowed_criteria.each do |expected_criterion|
      recognized_criteria[expected_criterion] = raw_criteria.delete(expected_criterion) if raw_criteria.key?(expected_criterion)
    end

    # Any leftovers are unwelcome
    unless raw_criteria.empty?
      raise ArgumentError, "Unrecognized filter criterion '#{raw_criteria.keys.first}'. Expected criteria: #{allowed_criteria.join(', ')}"
    end
    recognized_criteria
  end

  def fetch_from_backend(criteria)
    @table = []
    backend = AwsVpcSubnets::BackendFactory.create
    # Note: should we ever implement server-side filtering
    # (and this is a very good resource for that),
    # we will need to reformat the criteria we are sending to AWS.
    backend.describe_subnets(criteria).subnets.each do |sb_info|
      @table.push({
                    vpc_id:            sb_info.vpc_id,
                    subnet_id:         sb_info.subnet_id,
                    cidr_block:        sb_info.cidr_block,
                  })
    end
  end

  class BackendFactory
    extend AwsBackendFactoryMixin
  end

  class Backend
    class AwsClientApi < Backend
      AwsVpcSubnets::BackendFactory.set_default_backend self

      def describe_subnets(query)
        AWSConnection.new.ec2_client.describe_subnets(query)
      end
    end
  end
end
