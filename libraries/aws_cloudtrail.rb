# author: Viktor Yakovlyev

require 'aws_conn'

class AwsCloudTrail < Inspec.resource(1)
  name 'aws_cloudtrail'
  desc 'Verifies AWS CloudTrail'

  example "
    describe aws_cloudtrail('Default') do
      its('s3_bucket_name') { should eq 'mycorp-cloudtrail' }
    end

    describe aws_cloudtrail.where(is_multi_region_trail: true) do
      it { should exist }
    end
  "

  attr_reader :filter_data

  def initialize(name = nil)
    @conn = AWSConnection.new
    if name
      create_methods(name)
    else
      @filter_data = all_trails
    end
  end

  filter = FilterTable.create
  filter.add_accessor(:where)
        .add_accessor(:entries)
        .add(:exists?) { |x| !x.entries.empty? }
        .add(:name, field: :name)
        .add(:s3_bucket_name, field: :s3_bucket_name)
        .add(:s3_key_prefix, field: :s3_key_prefix)
        .add(:sns_topic_name, field: :sns_topic_name)
        .add(:sns_topic_arn, field: :sns_topic_arn)
        .add(:include_global_service_events, field: :include_global_service_events)
        .add(:is_multi_region_trail, field: :is_multi_region_trail)
        .add(:home_region, field: :home_region)
        .add(:trail_arn, field: :trail_arn)
        .add(:log_file_validation_enabled, field: :log_file_validation_enabled)
        .add(:cloud_watch_logs_log_group_arn, field: :cloud_watch_logs_log_group_arn)
        .add(:cloud_watch_logs_role_arn, field: :cloud_watch_logs_role_arn)
        .add(:kms_key_id, field: :kms_key_id)
        .add(:has_custom_event_selectors, field: :has_custom_event_selectors)
  filter.connect(self, :filter_data)

  def to_s
    'CloudTrail'
  end

  private

  def all_trails
    data = []

    # Converts AWS CloudTrail structs' methods to Hash entries for FilterTable
    @conn.cloudtrail_client.describe_trails.trail_list.each do |trail|
      data.push({})
      trail.members.each do |member|
        data.last[member] = trail.send(member)
      end
    end

    data
  end

  def create_methods(name)
    trails = @conn.cloudtrail_client.describe_trails.trail_list

    trail = trails.select { |t| t.name == name }

    # If multiple trails found by `name` then check if ARN passed
    trail = trails.select { |t| t.trail_arn == name } if trail.length > 1

    if trail.length > 1
      raise "Mutliple trails found for #{name}, please use ARN. " \
            'Example: arn:aws:sns:ap-southeast-1:872552916455:cloudtrail_sns'
    else
      # Convert struct methods to instance methods
      trail[0].members.each do |member|
        define_singleton_method(member) { trail[0].send(member) }
      end
    end
  end
end
