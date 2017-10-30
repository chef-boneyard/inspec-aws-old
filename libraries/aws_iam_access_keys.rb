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
end
