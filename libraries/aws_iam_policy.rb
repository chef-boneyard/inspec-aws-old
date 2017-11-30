# Authors: Simon Valow
# Authors: Chris Redekop

class AwsIamPolicy < Inspec.resource(1)
  name 'aws_iam_policy'
  desc 'Used to retrieve AWS IAM Policy'

  example "
    describe aws_iam_policy'AwsSupportAccess' do
      it { should exist} 
      its('attachment_count') { should be > 0 }
    end
  "

  def initialize(opts, conn = AWConnection.new)
    @policy = conn.iam_resource.policy(opts.is_a?(Hash) ? opts[:arn] : opts)
  end

  def name 
    raise "this policy does not exist" unless exists?
    @policy.policy_name 
  end

  def exists?
    !@policy.nil?
  end

  def attachment_count
    raise "this policy does not exist" unless exists?
    @policy.attachment_count
  end
end
