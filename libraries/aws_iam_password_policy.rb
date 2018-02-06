require '_aws'

# author: Viktor Yakovlyev
class AwsIamPasswordPolicy < Inspec.resource(1)
  name 'aws_iam_password_policy'
  desc 'Verifies iam password policy'

  example <<-EOX
    describe aws_iam_password_policy do
      its('requires_lowercase_characters?') { should be true }
    end

    describe aws_iam_password_policy do
      its('requires_uppercase_characters?') { should be true }
    end
EOX

  def initialize(conn = AWSConnection.new)
    @policy = conn.iam_resource.account_password_policy
  rescue Aws::IAM::Errors::NoSuchEntity
    @policy = nil
  end

  def exists?
    !@policy.nil?
  end

  def requires_lowercase_characters?
    @policy.require_lowercase_characters
  end

  def requires_uppercase_characters?
    @policy.require_uppercase_characters
  end

  def minimum_password_length
    @policy.minimum_password_length
  end

  def requires_numbers?
    @policy.require_numbers
  end

  def requires_symbols?
    @policy.require_symbols
  end

  def allows_users_to_change_password?
    @policy.allow_users_to_change_password
  end

  def expires_passwords?
    @policy.expire_passwords
  end

  def max_password_age
    raise 'this policy does not expire passwords' unless expires_passwords?
    @policy.max_password_age
  end

  def prevents_password_reuse?
    !@policy.password_reuse_prevention.nil?
  end

  def number_of_passwords_to_remember
    raise 'this policy does not prevent password reuse' \
      unless prevents_password_reuse?
    @policy.password_reuse_prevention
  end

  def to_s
    'IAM Password-Policy'
  end
end
