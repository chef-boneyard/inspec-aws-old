class AwsFlowLog < Inspec.resource(1)
  name 'aws_flow_log'
  desc 'Verifies settings for an IAM Flow Log'
  example "
    describe aws_flow_log(flow_log_id: ) do

    end
  "

  include AwsResourceMixin
  attr_reader :flow_log_id, :vpc_id, :subnet_id, :resource_id, :flow_log_status,
              :deliver_logs_error_message, :deliver_logs_permission_arn,
              :deliver_logs_status, :log_group_name, :traffic_type

  def to_s
    "Flow Log #{@flow_log_id}"
  end

  private

  def validate_params(raw_params)
    validated_params = check_resource_param_names(
      raw_params: raw_params,
      allowed_params: [:flow_log_id, :vpc_id, :subnet_id],
      allowed_scalar_name: :flow_log_id,
      allowed_scalar_type: String,
    )
    if validated_params.empty?
      raise ArgumentError, 'You must provide a flow_log_id to aws_flow_log.'
    end
    validated_params
  end

  def fetch_from_aws
    @resource_id = vpc_id ? vpc_id : subnet_id
    filters_array = []
    filters_array.push :flow_log_id unless @flow_log_id.nil?
    filters_array.push :resource_id unless @resource_id.nil?
    # Transform into filter format expected by AWS
    filters = []
    filters_array.each do |criterion_name|
      val = instance_variable_get("@#{criterion_name}".to_sym)
      next if val.nil?
      filters.push(
        {
          name: criterion_name.to_s.tr('_', '-'),
          values: [val],
        },
      )
    end

    begin
      flow_log = AwsFlowLog::BackendFactory.create.describe_flow_logs(filter: filters).flow_logs[0]
    rescue StandardError
      @exists = false
      return
    end
    if flow_log.nil?
      @exists = false
      return
    end

    @exists = true
    @flow_log_id                 = flow_log.flow_log_id
    @flow_log_status             = flow_log.flow_log_status
    @deliver_logs_error_message  = flow_log.deliver_logs_error_message
    @deliver_logs_permission_arn = flow_log.deliver_logs_permission_arn
    @deliver_logs_status         = flow_log.deliver_logs_status
    @log_group_name              = flow_log.log_group_name
    @resource_id                 = flow_log.resource_id
    @traffic_type                = flow_log.traffic_type
  end

  # Uses the SDK API to really talk to AWS
  class Backend
    class AwsClientApi
      BackendFactory.set_default_backend(self)
      def describe_flow_logs(query)
        AWSConnection.new.ec2_client.describe_flow_logs(query)
      end
    end
  end
end
