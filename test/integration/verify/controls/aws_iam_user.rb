mfa_not_enabled_user = attribute(
  'mfa_not_enabled_user',
  default: 'default.mfa_not_enabled_user',
  description: 'Name of IAM user mfa_not_enabled_user')

console_password_enabled_user = attribute(
  'console_password_enabled_user',
  default: 'default.console_password_enabled_user',
  description: 'Name of IAM user console_password_enabled_user')

access_key_user = attribute(
  'access_key_user',
  default: 'default.access_key_user',
  description: 'Name of IAM user access_key_user')

describe aws_iam_user(name: mfa_not_enabled_user) do
  it { should_not have_mfa_enabled }
  it { should_not have_console_password }
  it { should have_policies }
  it { should_not have_attached_policies }
end

describe aws_iam_user(name: console_password_enabled_user) do
  it { should have_console_password }
  it { should_not have_policies }
  it { should have_attached_policies }
end

aws_iam_user(name: access_key_user).access_keys.each { |access_key|
  describe access_key do
   it { should be_active }
  end
}
