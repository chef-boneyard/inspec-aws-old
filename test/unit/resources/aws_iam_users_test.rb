require 'helper'
require 'ostruct'
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

class AwsIamUsersTestFilterCriteria < Minitest::Test
  def setup
    # Reset to empty, that's harmless
    AwsIamUsers::Backend.select(Maiusb::Empty)
  end

  def test_users_empty_result_when_no_users_no_criteria
    users = AwsIamUsers.new.where { }
    assert users.entries.empty?
  end

  def test_users_all_returned_when_some_users_no_criteria
    AwsIamUsers::Backend.select(Maiusb::Basic)
    users = AwsIamUsers.new.where { }
    assert(3, users.entries.count)
  end

end

#=============================================================================#
#                        Test Fixture Classes
#=============================================================================#
module Maiusb
  class Empty < AwsIamUsers::Backend
    def list_users
      OpenStruct.new({
        users: []
      })
    end
  end

  class Basic < AwsIamUsers::Backend
    # arn, path, user_id omitted
    def list_users
      OpenStruct.new({
        users: [
          OpenStruct.new({
            user_name: 'alice',
            create_date: DateTime.parse('2017-10-10T16:19:30Z'),
            # Password last used is absent, never logged in w/ password
          }),
          OpenStruct.new({
            user_name: 'bob',
            create_date: DateTime.parse('2017-11-06T16:19:30Z'),
            password_last_used: DateTime.parse('2017-11-06T19:19:30Z'),
            }),
          OpenStruct.new({
            user_name: 'carol',
            create_date: DateTime.parse('2017-10-10T16:19:30Z'),
            password_last_used: DateTime.parse('2017-10-28T19:19:30Z'),
          }),
        ]
      })
    end
  end
end
