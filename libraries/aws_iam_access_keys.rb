class AwsIamAccessKeys < Inspec.resource(1)
  name 'aws_iam_access_keys'
  desc 'Verifies settings for AWS IAM Access Keys in bulk'
  example '
    describe aws_iam_access_keys do
      it { should_not exist }
    end
  '

  VALUED_CRITERIA = [
    :username,
    :id,
    :access_key_id,
  ].freeze

  # Constructor.  Args are reserved for row fetch filtering.
  def initialize(filter_criteria = {})
    filter_criteria = validate_filter_criteria(filter_criteria)
    @table = AccessKeyProvider.create.fetch(filter_criteria)
  end

  def validate_filter_criteria(criteria)
    # Allow passing a scalar string, the Access Key ID.
    criteria = { access_key_id: criteria } if criteria.kind_of? String
    raise "Unrecognized criteria for fetching Access Keys.  Use 'criteria: value' format." unless criteria.kind_of? Hash
  
    # id and access_key_id are aliases; standardize on access_key_id
    criteria[:access_key_id] = criteria.delete(:id) if criteria.key?(:id)
    if (criteria[:access_key_id] and criteria[:access_key_id] !~ /^AKIA[0-9A-Z]{16}$/) then
      raise "Incorrect format for Access Key ID - expected AKIA followed by 16 letters or numbers"
    end

    criteria.keys.each do |criterion| 
      unless VALUED_CRITERIA.include?(criterion)
        raise "Unrecognized filter criterion for aws_iam_access_keys, '#{criterion}'.  Valid choices are #{VALUED_CRITERIA.join(', ')}."
      end
    end

    criteria
  end

  # Underlying FilterTable implementation.
  filter = FilterTable.create
  filter.add_accessor(:where)
        .add_accessor(:entries)
        .add(:exists?) { |x| !x.entries.empty? }
        .add(:access_key_ids, field: :access_key_id) 
  filter.connect(self, :access_key_data)

  def access_key_data
    @table
  end

  def to_s
    'IAM Access Keys'
  end

  # Internal support class.  This is used to fetch
  # the users and access keys.  We have an abstract
  # class with a concrete AWS implementation provided here;
  # a few mock implementations are also provided in the unit tests.
  class AccessKeyProvider

    # Implementation of AccessKeyProvider which operates by looping over
    # all users, then fetching their access keys.
    # TODO: An alternate, more scalable implementation could be made
    # using the Credential Report.
    class AwsUserIterator < AccessKeyProvider
      def fetch(criteria)
        iam_client = AWSConnection.new.iam_client
        usernames = []
        if criteria.key?(:username)
          usernames.push criteria[:username]
        else
          # TODO: pagination check and resume
          usernames = iam_client.list_users.users.map { |u| u.user_name }
        end

        access_key_data = []
        usernames.each do |username|
          begin
            metadata = iam_client.list_access_keys(user_name: username).access_key_metadata
            access_key_data.concat(
              metadata.map do |metadata|
                {
                  access_key_id: metadata.access_key_id,
                  id: metadata.access_key_id,
                  username: username,
                  status: metadata.status,
                  create_date: metadata.create_date,
                  # Synthetics
                  active: metadata.status == 'Active',
                  create_age: Time.now - metadata.create_date,
                  # Separate API call aws iam get-access-key-last-used --access-key-id ...
                }
              end
            )
          rescue Aws::IAM::Errors::NoSuchEntity => exception
            # Swallow - a miss on search results should return an empty table
          end
        end
        access_key_data
      end
    end

    DEFAULT_PROVIDER = AwsIamAccessKeys::AccessKeyProvider::AwsUserIterator
    @selected_implementation = DEFAULT_PROVIDER

    # Use this to change what class is created by create().
    def self.select(klass)
      @selected_implementation = klass
    end

    def self.reset
      @selected_implementation = DEFAULT_PROVIDER
    end

    def self.create
      @selected_implementation.new
    end

    def fetch(_filter_criteria)
      raise 'Unimplemented abstract method - internal error.'
    end
  end
end
