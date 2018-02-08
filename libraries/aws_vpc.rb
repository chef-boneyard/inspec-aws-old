require '_aws'

class AwsVpc < Inspec.resource(1)
  name 'aws_vpc'
  desc 'Verifies settings for AWS VPC'
  example "
    describe aws_vpc do
      it { should be_default }
      its('cidr_block') { should cmp '10.0.0.0/16' }
    end
  "
  supports platform: 'aws'

  include AwsSingularResourceMixin

  def to_s
    "VPC #{vpc_id}"
  end

  [:cidr_block, :dhcp_options_id, :state, :vpc_id, :instance_tenancy, :is_default].each do |property|
    define_method(property) do
      @vpc[property]
    end
  end

  alias default? is_default

  private

  def validate_params(raw_params)
    validated_params = check_resource_param_names(
      raw_params: raw_params,
      allowed_params: [:vpc_id],
      allowed_scalar_name: :vpc_id,
      allowed_scalar_type: String,
    )

    if validated_params.key?(:vpc_id) && validated_params[:vpc_id] !~ /^vpc\-[0-9a-f]{8}/
      raise ArgumentError, 'aws_vpc VPC ID must be in the format "vpc-" followed by 8 hexadecimal characters.'
    end

    validated_params
  end

  def fetch_from_api
    backend = BackendFactory.create(inspec_runner)

    if @vpc_id.nil?
      filter = { name: 'isDefault', values: ['true'] }
    else
      filter = { name: 'vpc-id', values: [@vpc_id] }
    end

    resp = backend.describe_vpcs({ filters: [filter] })

    @vpc = resp.vpcs[0].to_h
    @vpc_id = @vpc[:vpc_id]
    @exists = !@vpc.empty?
  end

  class Backend
    class AwsClientApi < AwsBackendBase
      BackendFactory.set_default_backend(self)
      self.aws_client_class = Aws::EC2::Client

      def describe_vpcs(query)
        aws_service_client.describe_vpcs(query)
      end
    end
  end
end
