# author: Miles Tjandrawidjaja
class AwsIamRootUser < Inspec.resource(1)
  name 'aws_iam_root_user'
  desc 'Verifies settings for AWS root account'
  example "
    describe aws_iam_root_user do
      its('access_key_count') { should eq 0 }
    end
  "

  def initialize(conn = AWSConnection.new)
    @client = conn.iam_client
  end

  def access_key_count
    summary_account['AccountAccessKeysPresent']
  end

  def to_s
    'AWS Root-User'
  end

  private

  def summary_account
    @summary_account ||= @client.get_account_summary.summary_map
  end
end
