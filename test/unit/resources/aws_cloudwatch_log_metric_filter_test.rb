require 'helper'
require 'aws_cloudwatch_log_metric_filter'

# CWLMF = CloudwatchLogMetricFilter
# Abbreviation not used outside this file

class AwsCWLMFConstructor < Minitest::Test
  def setup
    AwsCloudwatchLogMetricFilter::Backend.select(AwsMockCWLMFBackend::Empty)
  end

  def test_constructor_some_args_required
    assert_raises(ArgumentError) { AwsCloudwatchLogMetricFilter.new }
  end

  def test_constructor_accepts_known_resource_params
    [
      :filter_name,
      :pattern,
      :log_group_name,
    ].each do | resource_param |
      AwsCloudwatchLogMetricFilter.new(resource_param => 'some_val')
    end
  end

  def test_constructor_reject_bad_resource_params
    assert_raises(ArgumentError) { AwsCloudwatchLogMetricFilter.new(i_am_a_martian: 'beep') }
  end
end

class AwsMockCWLMFBackend < AwsCloudwatchLogMetricFilter::Backend
  class Empty
  end
end