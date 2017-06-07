describe aws_iam_users() do
  its('has_mfa_enabled?') { should be false }
  its('has_console_password?') { should be false }
end

=begin
describe aws_iam_users('console_password_enabled_user') do
  its('has_console_password?') { should be true }
=end