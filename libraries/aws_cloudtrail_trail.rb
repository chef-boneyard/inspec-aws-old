class AwsCloudTrailTrail < Inspec.resource(1)
  name 'aws_cloudtrail_trail'
  desc 'Verifies individual AWS CloudTrail Trails'

  example <<~EOD
    describe aws_cloudtrail_trail('Default') do
      its('s3_bucket_name') { should eq 'mycorp-cloudtrail' }
    end

    describe aws_cloudtrail do
      it { should exist }
    end
  EOD

  # This is lifted directly from resource_mixin.rb; delete after PR 121 merges
  def initialize(resource_params = {})
    validate_params(resource_params).each do |param, value|
      instance_variable_set(:"@#{param}", value)
    end
    fetch_from_aws
  end

  # This is lifted directly from resource_mixin.rb; delete after PR 121 merges
  def check_resource_param_names(raw_params: {}, allowed_params: [], allowed_scalar_name: nil, allowed_scalar_type: nil)
    # Some resources allow passing in a single ID value.  Check and convert to hash if so.
    if allowed_scalar_name && !raw_params.is_a?(Hash)
      value_seen = raw_params
      if value_seen.is_a?(allowed_scalar_type)
        raw_params = { allowed_scalar_name => value_seen }
      else
        raise ArgumentError, 'If you pass a single value to the resource, it must ' \
        "be a #{allowed_scalar_type}, not an #{value_seen.class}."
      end
    end

    # Remove all expected params from the raw param hash
    validated_params = {}
    allowed_params.each do |expected_param|
      validated_params[expected_param] = raw_params.delete(expected_param) if raw_params.key?(expected_param)
    end

    # Any leftovers are unwelcome
    unless raw_params.empty?
      raise ArgumentError, "Unrecognized resource param '#{raw_params.keys.first}'. Expected parameters: #{allowed_params.join(', ')}"
    end

    validated_params
  end

  attr_reader :trail_name

  # This is lifted directly from resource_mixin.rb; delete after PR 121 merges
  def exists?
    @exists
  end

  def to_s
    "CloudTrail Trail #{trail_name}"
  end

  private

  def validate_params(raw_params)
    validated_params = check_resource_param_names(
    raw_params: raw_params,
    allowed_params: [:trail_name],
    allowed_scalar_name: :trail_name,
    allowed_scalar_type: String,
    )

    # If no name was provided, assume 'Default'.
    validated_params[:trail_name] ||= 'Default'
    validated_params
  end

  def fetch_from_aws
    backend = BackendFactory.create
    trails = backend.describe_trails(trail_name_list: [trail_name]).trail_list
    if trails.empty?
      @exists = false
      return
    end
    @exists = true
    # TODO - properties
  end

  # This class may be deleted once PR 121 is merged.
  class BackendFactory
    def self.create
      @selected_backend.new
    end

    def self.select(klass)
      @selected_backend = klass
    end
  end

  class Backend
    class AwsClientApi
      BackendFactory.select(self) # TODO: correct to set_default_backend when 121 merges
      def describe_trails(criteria)
        AWSConnection.new.cloudtrail_client.describe_trails(criteria)
      end
    end
  end
end
