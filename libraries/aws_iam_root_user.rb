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

  def has_mfa_enabled?
    summary_account['AccountMFAEnabled'] == 1
  end

  def has_hardware_mfa_enabled?
    virtual_mfa_devices.each do |device|
      if %r{arn:aws:iam::\d{12}:mfa\/root-account-mfa-device} =~
        device['serial_number']
        return false
      end
    end
    true
  end

  def to_s
    'AWS Root-User'
  end

  private

  def summary_account
    @summary_account ||= @client.get_account_summary.summary_map
  end

  def virtual_mfa_devices
    @client.list_virtual_mfa_devices.virtual_mfa_devices
  end
end
