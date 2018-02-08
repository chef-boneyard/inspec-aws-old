require '_aws'

class AwsIamAccessKeys < Inspec.resource(1)
  name 'aws_iam_access_keys'
  desc 'Verifies settings for AWS IAM Access Keys in bulk'
  example '
    describe aws_iam_access_keys do
      it { should_not exist }
    end
  '
  supports platform: 'aws'

  include AwsPluralResourceMixin

  def validate_params(raw_params)
    recognized_params = check_resource_param_names(
      raw_params: raw_params,
      allowed_params: [:username, :id, :access_key_id, :created_date],
      allowed_scalar_name: :access_key_id,
      allowed_scalar_type: String,
    )

    # id and access_key_id are aliases; standardize on access_key_id
    recognized_params[:access_key_id] = recognized_params.delete(:id) if recognized_params.key?(:id)
    if recognized_params[:access_key_id] and
       recognized_params[:access_key_id] !~ /^AKIA[0-9A-Z]{16}$/
      raise 'Incorrect format for Access Key ID - expected AKIA followed ' \
            'by 16 letters or numbers'
    end

    recognized_params
  end

  def fetch_from_api
    # TODO: this interface should be normalized to match the AWS API
    criteria = {}
    criteria[:username] = @username if defined? @username
    @table = BackendFactory.create(inspec_runner).fetch(criteria)
  end

  # Underlying FilterTable implementation.
  filter = FilterTable.create
  filter.add_accessor(:where)
        .add_accessor(:entries)
        .add(:exists?) { |x| !x.entries.empty? }
        .add(:access_key_ids, field: :access_key_id)
        .add(:created_date, field: :create_date)
        .add(:created_days_ago, field: :created_days_ago)
        .add(:created_with_user, field: :created_with_user)
        .add(:created_hours_ago, field: :created_hours_ago)
        .add(:usernames, field: :username)
        .add(:active, field: :active)
        .add(:inactive, field: :inactive)
        .add(:last_used_date, field: :last_used_date)
        .add(:last_used_hours_ago, field: :last_used_hours_ago)
        .add(:last_used_days_ago,  field: :last_used_days_ago)
        .add(:ever_used,           field: :ever_used)
        .add(:never_used,          field: :never_used)
        .add(:user_created_date,   field: :user_created_date)
  filter.connect(self, :table)

  def to_s
    'IAM Access Keys'
  end

  # Internal support class.  This is used to fetch
  # the users and access keys.  We have an abstract
  # class with a concrete AWS implementation provided here;
  # a few mock implementations are also provided in the unit tests.
  class Backend
    # Implementation of AccessKeyProvider which operates by looping over
    # all users, then fetching their access keys.
    # TODO: An alternate, more scalable implementation could be made
    # using the Credential Report.
    class AwsUserIterator < AwsBackendBase
      BackendFactory.set_default_backend(self)
      self.aws_client_class = Aws::IAM::Client

      def fetch(criteria)
        iam_client = aws_service_client

        user_details = {}
        if criteria.key?(:username)
          begin
            user_details[criteria[:username]] = iam_client.get_user(user_name: criteria[:username]).user
          rescue Aws::IAM::Errors::NoSuchEntity # rubocop:disable Lint/HandleExceptions
            # Swallow - a miss on search results should return an empty table
          end
        else
          # TODO: pagination check and resume
          iam_client.list_users.users.each do |info|
            user_details[info.user_name] = info
          end
        end

        access_key_data = []
        user_details.each_key do |username|
          begin
            user_keys = iam_client.list_access_keys(user_name: username)
                                  .access_key_metadata
            user_keys = user_keys.map do |metadata|
              {
                access_key_id: metadata.access_key_id,
                username: username,
                status: metadata.status,
                create_date: metadata.create_date, # DateTime.parse(metadata.create_date),
              }
            end

            # Copy in from user data
            # Synthetics
            user_keys.each do |key_info|
              add_synthetic_fields(key_info, user_details[username])
            end
            access_key_data.concat(user_keys)
          rescue Aws::IAM::Errors::NoSuchEntity # rubocop:disable Lint/HandleExceptions
            # Swallow - a miss on search results should return an empty table
          end
        end
        access_key_data
      end

      def add_synthetic_fields(key_info, user_details) # rubocop:disable Metrics/AbcSize
        key_info[:id] = key_info[:access_key_id]
        key_info[:active] = key_info[:status] == 'Active'
        key_info[:inactive] = key_info[:status] != 'Active'
        key_info[:created_hours_ago] = ((Time.now - key_info[:create_date]) / (60*60)).to_i
        key_info[:created_days_ago] = (key_info[:created_hours_ago] / 24).to_i
        key_info[:user_created_date] = user_details[:create_date]
        key_info[:created_with_user] = (key_info[:create_date] - key_info[:user_created_date]).abs < 1.0/24.0

        # Last used is a separate API call
        iam_client = aws_service_client
        last_used =
          iam_client.get_access_key_last_used(access_key_id: key_info[:access_key_id])
                    .access_key_last_used.last_used_date
        key_info[:ever_used] = !last_used.nil?
        key_info[:never_used] = last_used.nil?
        key_info[:last_used_time] = last_used
        return unless last_used
        key_info[:last_used_hours_ago] = ((Time.now - last_used) / (60*60)).to_i
        key_info[:last_used_days_ago] = (key_info[:last_used_hours_ago]/24).to_i
      end
    end
  end
end
