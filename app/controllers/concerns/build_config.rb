module BuildConfig
  extend ActiveSupport::Concern

  included do
    helper_method :config_for
  end

  private

  def config_for(object, clone_id: nil, params: {}, config_type: CustomConfig::SETTINGS)
    config = CustomConfig.find_or_initialize_for(object, config_type: config_type)
    config.object = object
    clone = object.class.find_by(id: clone_id)
    attributes = if config_type == CustomConfig::SETTINGS
                   CustomConfig.find_for(clone)&.config || CustomConfig.defaults(object) || {}
                 else
                   {}
                 end
    config.assign_attributes(config: attributes.merge(config.config || {}).merge(params.to_h))
    config
  end
end
