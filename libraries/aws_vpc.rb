class AwsVpc < Inspec.resource(1)
  name 'aws_vpc'
  desc 'Verifies settings for AWS VPC'
  example "
    describe aws_vpc do
      it { should be_default }
      its('cidr') { should be '10.0.0.0/16' }
    end
  "

  include AwsResourceMixin
  attr_reader :vpc_id

  def to_s
    "VPC #{vpc_id}"
  end

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

  def fetch_from_aws
    # TODO
  end

  class Backend
    class AwsClientApi
      BackendFactory.set_default_backend(self)

      def describe_vpcs(query)
        AWSConnection.new.ec2_client.describe_vpcs(query)
      end
    end
  end
end
