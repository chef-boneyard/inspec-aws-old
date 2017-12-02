class AwsCloudTrail < Inspec.resource(1)
  name 'aws_cloudtrail_trail'
  desc 'Verifies individual AWS CloudTrail Trails'

  example "
    describe aws_cloudtrail_trail('Default') do
      its('s3_bucket_name') { should eq 'mycorp-cloudtrail' }
    end

    describe aws_cloudtrail do
      it { should exist }
    end
  "
  end