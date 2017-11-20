# Intended to be pulled in via extend, not include
module AwsBackendFactoryMixin

  def create
    @selected_backend.new
  end

  def select(klass)
    @selected_backend = klass
  end

  alias_method :set_default_backend, :select
end