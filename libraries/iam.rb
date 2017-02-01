# author: Alex Bedley
# author: Steffanie Freeman

class Iam < Inspec.resource(1)
 name 'aws_iam_user'
  desc 'Verifies settings for AWS IAM user'

  example "
    describe aws_iam_user() do

	end
  "

  def initialize(name)
    @name = name
    conn = AWSConnection.new
    @iam_resource = conn.iam_resource
    @user = @iam_resource.user(@name)
  end

  def is_mfa_enabled?
    !@user.mfa_devices.first.nil?
  end

end