# author: Alex Bedley
# author: Steffanie Freeman
# author: Simon Varlow
# author: Chris Redekop
class AwsIamUsers < Inspec.resource(1)
  name 'aws_iam_users'
  desc 'Verifies settings for AWS IAM users'
  example '
    describe aws_iam_users.where(has_mfa_enabled?: false) do
      it { should_not exist }
    end

    describe aws_iam_users.where(has_console_password?: true) do
      it { should exist }
    end
  '

  filter = FilterTable.create
  filter.add_accessor(:where)
        .add_accessor(:entries)
        .add(:exists?) { |x| !x.entries.empty? }
  filter.connect(self, :collect_user_details)

  # No resource params => no overridden constructor
  # AWS API only offers filtering on path prefix; 
  # little other opportunity for server-side filtering.

  def collect_user_details
    backend = Backend.create
    aws_users_response = backend.list_users
    aws_users_response.users.map { |u| u.to_h }
  end

  def to_s
    'IAM Users'
  end

  #===========================================================================#
  #                        Backend Implementation
  #===========================================================================#
  class Backend
    #=====================================================#
    #                    API Definition
    #=====================================================#
    [
      :list_users,
    ].each do |method|
      define_method(:method) do |*_args|
        raise "Unimplemented abstract method #{method} - internal error"
      end
    end

    #=====================================================#
    #                 Concrete Implementation
    #=====================================================#
    # Uses AWS API to really talk to AWS
    class AwsClientApi < Backend
      def list_users(criteria)
        raise "AWS backend not implemented"
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
