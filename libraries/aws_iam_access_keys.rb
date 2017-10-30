class AwsIamAccessKeys < Inspec.resource(1)
  name 'aws_iam_access_keys'
  desc 'Verifies settings for AWS IAM Access Keys in bulk'
  example '
    describe aws_iam_access_keys do
      it { should_not exist }
    end
  '

  # Constructor.  Args are reserved for row fetch filtering.
  def initialize
  end

  # Underlying FilterTable implementation.
  filter = FilterTable.create
  filter.add_accessor(:where)
  filter.connect(self, :load_access_key_data)

  def load_access_key_data
    []
  end

  # Internal support class.  This is used to fetch
  # the users and access keys.  We have an abstract
  # class with a concrete AWS implementation provided here;
  # a mock implementation is also provided in the unit tests.
  class AccessKeyProvider
    # Implementation of AccessKeyProvider which operates by looping over
    # all users, then fetching their access keys.
    # TODO: An alternate, more scalable implementation could be made
    # using the Credential Report.
    class AwsUserIterator < AccessKeyProvider
      def fetch(filter_criteria)
        raise 'unimplemented concrete method'
      end
    end

    DEFAULT_PROVIDER = AwsIamAccessKeys::AccessKeyProvider::AwsUserIterator
    @selected_implementation = DEFAULT_PROVIDER

    # Use this to change what class is created by create().
    def self.select(klass)
      @selected_implementation = klass
    end

    def self.create
      @selected_implementation.new
    end

    def fetch(_filter_criteria)
      raise 'Unimplemented abstract method'
    end
  end
end
