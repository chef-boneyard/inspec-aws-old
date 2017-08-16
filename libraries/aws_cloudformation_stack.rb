# author: Christoph Hartmann

class AwsCloudformationStack < Inspec.resource(1)
  name 'aws_cloudformation_stack'
  desc 'Verifies settings for a CloudFormation stack'

  example "
    describe aws_cloudformation_stack do
      its('stack_list') { should eq nil }
    end
  "

  def initialize(opts = nil, conn = AWSConnection.new)
    @opts = opts
    @cf_client = conn.cf_client
  end

  filter = FilterTable.create
  filter.add_accessor(:where)
        .add_accessor(:entries)
        .add(:stack_ids,    field: :stack_id)
        .add(:stack_names,  field: :stack_name)
        .add(:stack_status, field: :stack_status)
        .add(:exists?) { |x| !x.entries.empty? }
  filter.connect(self, :stack_list)

  def to_s
    'AWS CloudFormation Stacks'
  end

  private

  def stack_list
    # require "pry"; binding.pry
    ls = @cf_client.list_stacks
    @stacks = ls.to_hash[:stack_summaries]
    @stacks
  end
end
