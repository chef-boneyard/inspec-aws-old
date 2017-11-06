require 'helper'
require 'aws_iam_users'

# Maiusb = Mock AwsIamUsers::Backend
# Abbreviation not used outside of this file

class AwsIamUsersTestConstructor < Minitest::Test
  def setup
    AwsIamUsers::Backend.select(Maiusb::Empty)
  end

  def test_users_no_params_does_not_explode
    AwsIamUsers.new
  end

  def test_users_all_params_rejected
    assert_raises(ArgumentError) { AwsIamUsers.new(something: 'somevalue') }
  end

end

#=============================================================================#
#                        Test Fixture Classes
#=============================================================================#
module Maiusb
  class Empty < AwsIamUsers::Backend
  end
end
