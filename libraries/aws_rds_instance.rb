require '_aws'

class AwsRdsInstance < Inspec.resource(1)
  name 'aws_rds_instance'
  desc 'Verifies settings for an rds instance'
  example "
    describe aws_rds_instance(db_instance_identifier: 'test-instance-id') do
      it { should exist }
    end
  "

  include AwsResourceMixin
  attr_reader :db_id

  def to_s
    "RDS Instance #{@db_id}"
  end

  private

  def validate_params(raw_params)
    validated_params = check_resource_param_names(
      raw_params: raw_params,
      allowed_params: [:db_id],
      allowed_scalar_name: :db_id,
      allowed_scalar_type: String,
    )
    if validated_params.empty? or !validated_params.key?(:db_id)
      raise ArgumentError, 'You must provide an id for the aws_rds_instance.'
    end

    if validated_params.key?(:db_id) && validated_params[:db_id] !~ /^[a-z]{1}[0-9a-z\-]{0,62}$/
      raise ArgumentError, 'aws_rds_instance Database Instance ID must be in the format: start with a letter followed by up to 62 letters/numbers/hyphens.'
    end

    validated_params
  end

  def fetch_from_aws
    backend = AwsRdsInstance::BackendFactory.create

    # Transform into filter format expected by AWS
    filters = []
    [
        :db_id,
    ].each do |criterion_name|
      val = instance_variable_get("@#{criterion_name}".to_sym)
      next if val.nil?
    end
    begin
      dsg_response = backend.describe_db_instances(db_instance_identifier: db_id)
    rescue StandardError
        @exists = false
        return
    end

    if dsg_response.db_instances.empty?
      @exists = false
      return
    end

    @exists = true
    @db_id = dsg_response.db_instances[0].db_instance_identifier
  end

  # Uses the SDK API to really talk to AWS
  class Backend
    class AwsClientApi
      BackendFactory.set_default_backend(self)

      def describe_db_instances(query)
        AWSConnection.new.rds_client.describe_db_instances(query)
      end
    end
  end
end
