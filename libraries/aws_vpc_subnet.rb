# author: Matthew Dromazos

require '_aws'

class AwsVpcSubnet < Inspec.resource(1)
  name 'aws_vpc_subnet'
  desc 'This resource is used to test the attributes of a vpc subnet'
  example "
    describe aws_vpc_subnet('vpc_id') do
      it { should exist }
    end
  "

  include AwsResourceMixin
  attr_reader :vpc_id, :subnet_id

  def to_s
    "VPC Subnet #{@subnet_id}"
  end

  private

  def validate_params(raw_params)
    validated_params = check_resource_param_names(
      raw_params: raw_params,
      allowed_params: [:vpc_id],
      allowed_scalar_name: [:vpc_id],
      allowed_scalar_type: String,
    )
    if validated_params.empty? or !validated_params.key?(:vpc_id)
      raise ArgumentError, 'You must provide a vpc_id to aws_vpc_subnet.'
    end
    validated_params
  end

  def fetch_from_aws
    backend = AwsVpcSubnet::BackendFactory.create

    # Transform into filter format expected by AWS
    filters = []
    [
      :vpc_id,
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
    begin
      ds_response = backend.describe_subnets(filters: filters)
      @exists = true
    rescue StandardError
      @exists = false
      return
    end

    if ds_response.subnets.empty?
      @exists = false
      return
    end

    @vpc_id = ds_response.subnets[0].vpc_id
    @subnet_id = ds_response.subnets[0].subnet_id
  end

  # Uses the SDK API to really talk to AWS
  class Backend
    class AwsClientApi
      BackendFactory.set_default_backend(self)
      def describe_subnets(query)
        AWSConnection.new.ec2_client.describe_subnets(query)
      end
    end
  end
end
