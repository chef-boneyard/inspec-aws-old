<<<<<<< HEAD
mfa_not_enabled_user = attribute(
  'mfa_not_enabled_user',
  default: 'default.mfa_not_enabled_user',
  description: 'Name of IAM user mfa_not_enabled_user')

console_password_enabled_user = attribute(
  'console_password_enabled_user',
  default: 'default.console_password_enabled_user',
  description: 'Name of IAM user console_password_enabled_user')

describe aws_iam_user(mfa_not_enabled_user) do
=======

fixtures = {}
[
  'iam_user_recall_hit',
  'iam_user_recall_miss',
  'iam_user_no_mfa_enabled',
  'iam_user_has_console_password',
  'iam_user_with_access_key',
].each do |fixture_name|
  fixtures[fixture_name] = attribute(
    fixture_name,
    default: "default.#{fixture_name}",
    description: 'See ../build/iam.tf',
  )
end

#-------------------  Recall / Miss -------------------#
describe aws_iam_user(name: fixtures['iam_user_recall_hit']) do
  it { should exist }
end

describe aws_iam_user(name: fixtures['iam_user_recall_miss']) do
  it { should_not exist }
end

#------------- Property - has_mfa_enabled -------------#

# TODO: fixture and test for has_mfa_enabled

describe aws_iam_user(name: fixtures['iam_user_no_mfa_enabled']) do
>>>>>>> Split IAM fixtures into their own file; add TODOs for missing tests; create naming scheme for fixtures
  it { should_not have_mfa_enabled }
  it { should_not have_console_password } # TODO: this is working by accident, we should have a dedicated fixture
end

<<<<<<< HEAD
describe aws_iam_user(console_password_enabled_user) do
  it { should have_console_password }
end
=======
#---------- Property - has_console_password -----------#

describe aws_iam_user(name: fixtures['iam_user_has_console_password']) do
  it { should have_console_password }
end

#------------- Property - access_keys -------------#

aws_iam_user(name: fixtures['iam_user_with_access_key']).access_keys.each { |access_key|
  describe access_key do
   it { should be_active }
  end
}
>>>>>>> Split IAM fixtures into their own file; add TODOs for missing tests; create naming scheme for fixtures
