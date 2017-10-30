:has_creation_age_greater_than,
    :has_usage_age_greater_than,
    :active,
    :ever_used,

    BOOLEAN_CRITERIA = [:active, :ever_used].freeze
    criteria = { active: true } if criteria == :active
    criteria = { ever_used: true } if criteria == :ever_used

    @boolean_criteria = [:active, :ever_used]

    # Boolean criterion are allowed valueless (implicit true)
  def test_boolean_criteria_when_used_in_constructor_with_implicit_value
    @boolean_criteria.each do |criterion|
      AwsIamAccessKeys.new(criterion)
    end
  end

  def test_boolean_criteria_when_used_in_where_with_implicit_value
    @boolean_criteria.each do |criterion|
      AwsIamAccessKeys.new.where(criterion)
    end
  end
