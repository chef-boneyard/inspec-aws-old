require 'helper'
require 'aws_flow_log'

# MAFLSB = MockAwsFlowLogSingularBackend
# Abbreviation not used outside this file

#=============================================================================#
#                            Constructor Tests
#=============================================================================#
class AwsFlowLogConstructorTest < Minitest::Test

  def setup
    AwsFlowLog::BackendFactory.select(MAFLSB::Basic)
  end

  def test_rejects_empty_params
    assert_raises(ArgumentError) { AwsFlowLog.new }
  end

  def test_accepts_flow_log_id_as_scalar
    AwsFlowLog.new('fl-12345678')
  end

  def test_accepts_params_with_vpc_id_as_hash
    AwsFlowLog.new(vpc_id: 'vpc-12345678')
  end

  def test_accepts_params_with_subnet_id_as_hash
    AwsFlowLog.new(subnet_id: 'subnet-12345678')
  end

  def test_rejects_unrecognized_params
    assert_raises(ArgumentError) { AwsFlowLog.new(invalid: 9) }
  end
end

#=============================================================================#
#                               Search / Recall
#=============================================================================#
class AwsKmsKeyRecallTest < Minitest::Test

  def setup
    AwsFlowLog::BackendFactory.select(MAFLSB::Basic)
  end

  def test_search_hit_via_scalar_works
    assert AwsFlowLog.new('fl-12345678').exists?
  end

  def test_search_hit_via_hash_with_vpc_id_works
    assert AwsFlowLog.new(vpc_id: 'vpc-12345678').exists?
  end

  def test_search_hit_via_hash_with_subnet_id_works
    assert AwsFlowLog.new(subnet_id: 'subnet-12345678').exists?
  end

  def test_search_miss_is_not_an_exception
    refute AwsFlowLog.new(flow_log_id: 'fl-00000000').exists?
  end
end

#=============================================================================#
#                               Properties
#=============================================================================#
class AwsFlowLogPropertiesTest < Minitest::Test

  def setup
    AwsFlowLog::BackendFactory.select(MAFLSB::Basic)
  end

  def test_property_flow_id
    assert_equal('fl-12345678', AwsFlowLog.new('fl-12345678').flow_log_id)
  end

  def test_property_vpc_id
    assert_equal('vpc-12345678', AwsFlowLog.new(vpc_id: 'vpc-12345678').vpc_id)
  end

  def test_property_subnet_id
    assert_equal('subnet-12345678', AwsFlowLog.new(subnet_id: 'subnet-12345678').subnet_id)
  end

  def test_property_deliver_logs_error_message
    assert_equal('Access error', AwsFlowLog.new(flow_log_id: 'fl-12345678').deliver_logs_error_message)
    assert_nil(AwsFlowLog.new(flow_log_id: 'fl-00000000').deliver_logs_error_message)
  end

  def test_property_deliver_logs_permission_arn
    assert_equal('arn:aws:iam::123456789101:role/flowlogsrole', AwsFlowLog.new(flow_log_id: 'fl-12345678').deliver_logs_permission_arn)
    assert_nil(AwsFlowLog.new(flow_log_id: 'fl-00000000').deliver_logs_permission_arn)
  end

  def test_property_log_group_name
    assert_equal('FlowLogsForSubnetA', AwsFlowLog.new(flow_log_id: 'fl-12345678').log_group_name)
    assert_nil(AwsFlowLog.new(flow_log_id: 'fl-00000000').log_group_name)
  end

  def test_property_traffic_type
    assert_equal('ALL', AwsFlowLog.new(flow_log_id: 'fl-12345678').traffic_type)
    assert_nil(AwsFlowLog.new(flow_log_id: 'fl-00000000').traffic_type)
  end
end

#=============================================================================#
#                               Matchers
#=============================================================================#
class AwsFlowLogMatchersTest < Minitest::Test

  def setup
    AwsFlowLog::BackendFactory.select(MAFLSB::Basic)
  end

  def test_matcher_active
    assert AwsFlowLog.new(flow_log_id: 'fl-12345678').active?
    refute AwsFlowLog.new(flow_log_id: 'fl-87654321').active?
  end

  def test_matcher_has_logs_delivered_ok
    assert AwsFlowLog.new(flow_log_id: 'fl-12345678').has_logs_delivered_ok?
    refute AwsFlowLog.new(flow_log_id: 'fl-87654321').has_logs_delivered_ok?
  end

end


#=============================================================================#
#                               Test Fixtures
#=============================================================================#
module MAFLSB
  class Basic < AwsFlowLog::Backend
    def describe_flow_logs(query)
      fixtures = [
       OpenStruct.new({
         deliver_logs_error_message: 'Access error',
         resource_id: 'vpc-12345678',
         deliver_logs_permission_arn: 'arn:aws:iam::123456789101:role/flowlogsrole',
         flow_log_status: 'ACTIVE',
         log_group_name: 'FlowLogsForSubnetA',
         traffic_type: 'ALL',
         flow_log_id: 'fl-12345678',
         deliver_logs_status: nil,
        }),
        OpenStruct.new({
          deliver_logs_error_message: nil,
          resource_id: 'subnet-12345678',
          deliver_logs_permission_arn: 'arn:aws:iam::123456789101:role/flowlogsrole',
          deliver_log_status: nil,
          flow_log_status: nil,
          log_group_name: 'FlowLogsForSubnetB',
          traffic_type: 'ALL',
          flow_log_id: 'fl-87654321',
          deliver_logs_status: 'FAILED',
        }),
      ]
      selected = fixtures.detect do |fixture|
        fixture.flow_log_id == query[:filter][0][:values][0] or fixture.resource_id == query[:filter][0][:values][0]
      end

      return OpenStruct.new({ flow_logs: [selected] }) unless selected.nil?
      OpenStruct.new({ flow_logs: [] })
    end
  end
end
