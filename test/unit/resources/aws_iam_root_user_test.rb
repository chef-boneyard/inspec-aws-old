# author: Miles Tjandrawidjaja
require 'helper'
require 'aws_iam_root_user'

class AwsIamRootUserTest < Minitest::Test
  def setup
    @mock_conn = Minitest::Mock.new
    @mock_client = Minitest::Mock.new

    @mock_conn.expect :iam_client, @mock_client
  end

  def test_has_access_key_returns_true_from_summary_account
    test_summary_map = OpenStruct.new(
      summary_map: { 'AccountAccessKeysPresent' => 1 },
    )
    @mock_client.expect :get_account_summary, test_summary_map

    assert_equal true, AwsIamRootUser.new(@mock_conn).has_access_key?
  end

  def test_has_access_key_returns_false_from_summary_account
    test_summary_map = OpenStruct.new(
      summary_map: { 'AccountAccessKeysPresent' => 0 },
    )
    @mock_client.expect :get_account_summary, test_summary_map

    assert_equal false, AwsIamRootUser.new(@mock_conn).has_access_key?
  end

  def test_has_mfa_enabled_returns_true_when_account_mfa_devices_is_one
    test_summary_map = OpenStruct.new(
      summary_map: { 'AccountMFAEnabled' => 1 },
    )
    @mock_client.expect :get_account_summary, test_summary_map

    assert_equal true, AwsIamRootUser.new(@mock_conn).has_mfa_enabled?
  end

  def test_has_mfa_enabled_returns_false_when_account_mfa_devices_is_zero
    test_summary_map = OpenStruct.new(
      summary_map: { 'AccountMFAEnabled' => 0 },
    )
    @mock_client.expect :get_account_summary, test_summary_map

    assert_equal false, AwsIamRootUser.new(@mock_conn).has_mfa_enabled?
  end

  def test_has_virtual_mfa_devices_returns_false_when_no_virtual_mfa_for_root
    test_virtual_mfa_devices = OpenStruct.new(
      virtual_mfa_devices: [
        { 'serial_number' => 'arn:aws:iam::123456789012:mfa/TestUser' },
        { 'serial_number' => 'arn:aws:iam::123456789012:mfa/TestUser' },
      ],
    )
    @mock_client.expect :list_virtual_mfa_devices, test_virtual_mfa_devices

    assert_equal false, AwsIamRootUser.new(@mock_conn).has_virtual_mfa_devices?
  end

  def test_has_virtual_mfa_devices_returns_true_when_virtual_mfa_for_root
    test_virtual_mfa_devices = OpenStruct.new(
      virtual_mfa_devices: [
        { 'serial_number' => 'arn:aws:iam::123456789012:mfa/' },
        { 'serial_number' =>
          'arn:aws:iam::123456789012:mfa/root-account-mfa-device' },
      ],
    )
    @mock_client.expect :list_virtual_mfa_devices, test_virtual_mfa_devices

    assert_equal true, AwsIamRootUser.new(@mock_conn).has_virtual_mfa_devices?
  end

  def test_has_virtual_mfa_devices_returns_false_when_no_virtual_mfa_devices
    test_virtual_mfa_devices = OpenStruct.new(
      virtual_mfa_devices: [],
    )
    @mock_client.expect :list_virtual_mfa_devices, test_virtual_mfa_devices

    assert_equal false, AwsIamRootUser.new(@mock_conn).has_virtual_mfa_devices?
  end
end
