require 'ostruct'
require 'helper'
require 'aws_sns_topic'

# MSNB = MockSnsBackend
# Abbreviation not used outside this file

#=============================================================================#
#                            Constructor Tests
#=============================================================================#
class AwsSnsTopicConstructorTest < Minitest::Test
  def setup
    AwsSnsTopic::Backend.select(AwsMSNB::NoSubscriptions)
  end

  def test_constructor_some_args_required
    assert_raises(ArgumentError) { AwsSnsTopic.new }
  end

  def test_constructor_accepts_scalar_arn
    AwsSnsTopic.new('arn:aws:sns:us-east-1:123456789012:some-topic')
  end

  def test_constructor_accepts_arn_as_hash
    AwsSnsTopic.new(arn: 'arn:aws:sns:us-east-1:123456789012:some-topic')    
  end
  
  def test_constructor_rejects_unrecognized_resource_params
    assert_raises(ArgumentError) { AwsSnsTopic.new(beep: 'boop') }
  end
    
  def test_constructor_rejects_non_arn_formats
    [
      'not-even-like-an-arn',
      'arn:::::', # Empty
      'arn::::::', # Too many colons
      'arn:aws::us-east-1:123456789012:some-topic', # Omits SNS service
      'arn::sns:us-east-1:123456789012:some-topic', # Omits partition
    ].each do |example|
      assert_raises(ArgumentError) { AwsSnsTopic.new(arn: example) }
    end
  end

  def test_constructor_accepts_arn_variants_as_hash
    [
      'arn:aws:sns:*:123456789012:some-topic',  # All-region
      'arn:aws:sns:us-east-1::some-topic', # Default account
    ].each do |variant|
      AwsSnsTopic.new(arn: variant)
    end
  end
end


#=============================================================================#
#                               Test Fixtures
#=============================================================================#

module AwsMSNB

  class Miss < AwsSnsTopic::Backend
    def get_topic_attributes(criteria)
      raise Aws::IAM::Errors::NoSuchEntity.new("No SNS topic for #{criteria[:topic_arn]}", 'Nope')
    end
  end

  class NoSubscriptions < AwsSnsTopic::Backend
    def get_topic_attributes(_criteria)
      OpenStruct.new({
        attributes: { # Note that this is a plain hash, odd for AWS SDK
          # Many other attributes available, see 
          # http://docs.aws.amazon.com/sdkforruby/api/Aws/SNS/Types/GetTopicAttributesResponse.html
          "SubscriptionsConfirmed" => 0
        }
      })
    end
  end

  class OneSubscription < AwsSnsTopic::Backend
    def get_topic_attributes(_criteria)
      OpenStruct.new({
        attributes: { # Note that this is a plain hash, odd for AWS SDK
          # Many other attributes available, see 
          # http://docs.aws.amazon.com/sdkforruby/api/Aws/SNS/Types/GetTopicAttributesResponse.html
          "SubscriptionsConfirmed" => 1
        }
      })
    end
  end
end