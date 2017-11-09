class AwsSnsTopic < Inspec.resource(1)
  name 'aws_sns_topic'
  desc 'Verifies settings for an SNS Topic'
  example "
    describe aws_sns_topic('arn:aws:sns:us-east-1:123456789012:some-topic') do
      it { should exist }
      its('confirmed_subscriber_count') { should_not be_zero }
    end
  "

  def initialize(opts)
  end

  class Backend
    #=====================================================#
    #                    API Definition
    #=====================================================#
    [
      :get_topic_attributes,
    ].each do |method|
      define_method(:method) do |*_args|
        raise "Unimplemented abstract method #{method} - internal error"
      end
    end

    #=====================================================#
    #                 Concrete Implementation
    #=====================================================#
    # Uses the SDK API to really talk to AWS
    class AwsClientApi < Backend
      def get_topic_attributes(criteria)
        raise 'TODO'
      end
    end

    #=====================================================#
    #                   Factory Interface
    #=====================================================#
    # TODO: move this to a mix-in
    DEFAULT_BACKEND = AwsClientApi
    @selected_backend = DEFAULT_BACKEND

    def self.create
      @selected_backend.new
    end

    def self.select(klass)
      @selected_backend = klass
    end
  end  
end