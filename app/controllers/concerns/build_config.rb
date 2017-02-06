module BuildConfig
  extend ActiveSupport::Concern

  included do
    helper_method :config_for
  end

  private

  def config_for(owner, clone_id: nil, params: {}, config_type: CustomConfig::SETTINGS)
    config = CustomConfig.find_or_initialize_for(owner, config_type: config_type)
    config.owner = owner # needed for a new portfolio ID is nil, this is then updated when it is saved.
    clone = owner.class.find_by(id: clone_id)
    attributes = if config_type == CustomConfig::SETTINGS
                   CustomConfig.find_for(clone)&.config || CustomConfig.defaults(owner) || {}
                 else
                   {}
                 end
    config.assign_attributes(config: attributes.merge(config.config || {}).merge(params.to_h))
    config
  end
end
