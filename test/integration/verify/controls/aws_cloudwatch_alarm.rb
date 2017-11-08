alarm_01 = attribute(
  'cloudwatch_alarm_01',
  default: 'default.cloudwatch_alarm',
  description: 'Name of Cloudwatch Alarm')

  # TODO: this is likely to be a multiple hit
  describe aws_cloudwatch_alarm(
    metric_name: 'CPUUtilization',
    metric_namespace: 'AWS/EC2',
  ) do
    it { should exist }
  end

  describe aws_cloudwatch_alarm(
    metric_name: 'NopeNope',
    metric_namespace: 'Nope',
  ) do
    it { should_not exist }
  end
