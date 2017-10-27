access_key_user = attribute(
  'access_key_user',
  default: 'default.access_key_user',
  description: 'Name of IAM user access_key_user')

access_key_id = attribute(
    'access_key_arn',
    default: 'default.access_key_user',
    description: 'Access Key ID of access key of IAM user access_key_user')

describe aws_iam_access_key(username: 'not-a-user', 'id': 'not-an-id') do
  it { should_not exist }
end

describe aws_iam_access_key(username: access_key_user, 'id': access_key_id) do
  it { should exist }
  # TODO - check last used, created, other key metadata
end

describe aws_iam_access_keys do
  it { should exist }
end

describe aws_iam_access_keys.where(username: access_key_user) do
  its('length') { should be 1 }
  it { should include access_key_id }
  its('first.id') { should be access_key_id } 
end