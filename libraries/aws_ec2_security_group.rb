class AwsEc2SecurityGroup < Inspec.resource(1)
  name 'aws_ec2_security_group'
  desc 'Verifies settings for an individual AWS Security Group.'
  example '
    describe aws_ec2_security_group("sg-12345678") do
      it { should exist }
    end
  '

  include AwsResourceMixin
  attr_reader :group_id

  def to_s
    'EC2 Security Group'
  end

  private

  def validate_params(raw_params)
    recognized_params = check_resource_param_names(
      raw_params: raw_params,
      allowed_params: [:id, :group_id, :group_name, :vpc_id],
      allowed_scalar_name: :group_id,
      allowed_scalar_type: String,
    )

    # id is an alias for group_id
    recognized_params[:group_id] = recognized_params.delete(:id) if recognized_params.key?(:id)

    if recognized_params.key?(:group_id) && recognized_params[:group_id] !~ /^sg\-[0-9a-f]{8}/
      raise ArgumentError, 'aws_ec2_security_group security group ID must be in the format "sg-" followed by 8 hexadecimal characters.'
    end

    if recognized_params.key?(:vpc_id) && recognized_params[:vpc_id] !~ /^vpc\-[0-9a-f]{8}/
      raise ArgumentError, 'aws_ec2_security_group VPC ID must be in the format "vpc-" followed by 8 hexadecimal characters.'
    end

    validated_params = recognized_params

    if validated_params.empty?
      raise ArgumentError, 'You must provide parameters to aws_ec2_security_group, such as group_name, group_id, or vpc_id.g_group.'
    end
    validated_params
  end

  def fetch_from_aws
    # TODO
  end

  class Backend
    class AwsClientApi < Backend
      AwsEc2SecurityGroup::BackendFactory.set_default_backend self

      def describe_security_groups(query)
        AWSConnection.new.ec2_client.describe_security_groups(query)
      end
    end
  end
end
