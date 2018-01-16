class AwsIamPolicy < Inspec.resource(1)
  name 'aws_iam_policy'
  desc 'Verifies settings for individual AWS IAM Policy'
  example "
    describe aws_iam_policy('AWSSupportAccess') do
      it { should be_attached }
    end
  "

  include AwsResourceMixin
  attr_reader :test
  def to_s
    "Policy #{@policy_name}"
  end

  [
    :arn, :default_version_id, :attachment_count, :is_attachable,
    :attached_users, :attached_groups, :attached_roles
  ].each do |property|
    define_method(property) do
      @policy[property]
    end
  end

  alias attachable? is_attachable

  def attached?
    !attachment_count.zero?
  end

  private

  def validate_params(raw_params)
    validated_params = check_resource_param_names(
      raw_params: raw_params,
      allowed_params: [:policy_name],
      allowed_scalar_name: :policy_name,
      allowed_scalar_type: String,
    )

    if validated_params.empty?
      raise ArgumentError, 'You must provide parameter to aws_iam_policy: policy name.'
    end

    validated_params
  end

  def fetch_from_aws
    backend = AwsIamPolicy::BackendFactory.create

    criteria = { max_items: 1000 } # maxItems max value is 1000
    resp = backend.list_policies(criteria)
    @test = resp
    @policy = resp.policies.select { |policy| policy.policy_name == @policy_name }.first.to_h
    @exists = !@policy.empty?

    return unless @exists
    criteria = { policy_arn: arn }
    resp = backend.list_entities_for_policy(criteria)
    @policy[:attached_groups] = resp.policy_groups.map(&:group_name)
    @policy[:attached_users]  = resp.policy_users.map(&:user_name)
    @policy[:attached_roles]  = resp.policy_roles.map(&:role_name)
  end

  class Backend
    class AwsClientApi
      BackendFactory.set_default_backend(self)

      def list_policies(criteria)
        AWSConnection.new.iam_client.list_policies(criteria)
      end

      def list_entities_for_policy(criteria)
        AWSConnection.new.iam_client.list_entities_for_policy(criteria)
      end
    end
  end
end
