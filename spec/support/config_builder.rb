class ConfigBuilder
  def self.helper_method(*)
  end

  include BuildConfig

  def initialize(object)
    @config = config_for(object)
  end

  def save
    @config.save
  end
end
