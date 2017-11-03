require 'aws_conn'

class AwsCloudwatchLogMetricFilter < Inspec.resource(1)
  name 'aws_cloudwatch_log_metric_filter'
  desc 'Verifies individual Cloudwatch Log Metric Filters'
  example <<-EOX
  # Look for a LMF by its filter name and log group name.  This combination
  # will always either find at most one LMF - no duplicates.
  describe aws_cloudwatch_log_metric_filter(
    filter_name: 'my-filter',
    log_group_name: 'my-log-group'
  ) do
    it { should exist }
  end

  # Search for an LMF by pattern and log group.
  # This could result in an error if the results are not unique.
  describe aws_cloudwatch_log_metric_filter(
    log_group_name:  'my-log-group',
    pattern: 'my-filter'
  ) do
    it { should exist }
  end
EOX

  RESOURCE_PARAMS = [
    :filter_name,
    :log_group_name,
    :pattern,
  ].freeze

  def initialize(resource_params)
    resource_params = validate_resource_params(resource_params)
  end

  private
  def validate_resource_params(resource_params)
    unless resource_params.is_a? Hash
      raise ArgumentError.new(
        'Unrecognized format for aws_cloudwatch_log_metric_filter parameters ' \
        " - use (param: 'value') format "
      )
    end
    resource_params.keys.each do |param_name|
      unless RESOURCE_PARAMS.include?(param_name)
        raise ArgumentError.new(
          "Unrecognized parameter '#{param_name}' for aws_cloudwatch_log_metric_filter." \
          " Expected one of #{RESOURCE_PARAMS.join(', ')}."
        )
      end
    end
  end

  class Backend
    #=====================================================#
    #                    API Definition
    #=====================================================#
    [
    ].each do |method|
      define_method(:method) do |*_args|
        raise "Unimplemented abstract method #{method} - internal error" 
      end 
    end

    #=====================================================#
    #                 Concrete Implementation
    #=====================================================#
    # Uses the cloudwatch API to really talk to AWS
    class AwsClientApi
    end

    

    #=====================================================#
    #                   Factory Interface
    #=====================================================#
    # TODO: move this to a mix-in
    DEFAULT_BACKEND = AwsClientApi
    @selected_backend = DEFAULT_BACKEND

    def self.create
      @selected_backend.new
    end

    def self.select(klass)
      @selected_backend = klass
    end

    def self.reset
      select(DEFAULT_BACKEND)
    end
  end
end