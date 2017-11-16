module AwsResourceMixin

  def initialize(resource_params)
    validate_params(resource_params).each do |param, value|
      instance_variable_set(:"@#{param}", value)
    end
    fetch_from_aws
  end

end