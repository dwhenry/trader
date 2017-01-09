module BuildConfig
  extend ActiveSupport::Concern

  included do
    helper_method :config_for
  end

  private

  def config_for(object, clone_id: nil, params: {})
    config = CustomConfig.find_or_initialize_for(object)
    config.object = object
    clone = object.class.find_by(id: clone_id)
    attributes = (clone && CustomConfig.find_for(clone)&.config) || CustomConfig.defaults(object) || {}
    config.assign_attributes(config: attributes.merge(params.to_h))
    config
  end
end
