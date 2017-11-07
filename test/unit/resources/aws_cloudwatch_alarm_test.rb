require 'ostruct'
require 'helper'
require 'aws_cloudwatch_alarm'

# MCWAB = MockCloudwatchAlarmBackend
# Abbreviation not used outside this file

#=============================================================================#
#                            Constructor Tests
#=============================================================================#
class AwsCWAConstructor < Minitest::Test
  def setup
    AwsCloudwatchAlarm::Backend.select(AwsMCWAB::Empty)
  end

  def test_constructor_some_args_required
    assert_raises(ArgumentError) { AwsCloudwatchAlarm.new }
  end

  def test_constructor_accepts_known_resource_params_combos
    [
      { metric_name: 'some-val', metric_namespace: 'some-val' },
    ].each do |combo|
      AwsCloudwatchAlarm.new(combo)
    end
  end

  def test_constructor_rejects_bad_resource_params_combos
    [
      { metric_name: 'some-val' },
      { metric_namespace: 'some-val' },
    ].each do |combo|
      assert_raises(ArgumentError) { AwsCloudwatchAlarm.new(combo) }
    end
  end

  def test_constructor_reject_unknown_resource_params
    assert_raises(ArgumentError) { AwsCloudwatchAlarm.new(beep: 'boop') }    
  end
end

module AwsMCWAB
  class Empty < AwsCloudwatchAlarm::Backend
  end
end