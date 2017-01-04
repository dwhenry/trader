class CustomConfig < ApplicationRecord
  CONFIG_TYPES = [
    SETTINGS = 'settings'
  ].freeze

  DEFAULT_CONFIG = {
    'Business' => { reporting_currency: 'USD' },
    'Portfolio' => { allow_negative_positions: 'no' },
  }.freeze

  CONFIG_OPTIONS = {
    allow_negative_positions: { type: :radio, options: %w(yes no) },
    reporting_currency: { type: :select, options: %w(AUD USD) }
  }.freeze

  validates :config_type,
            uniqueness: { scope: [:object_type, :object_id] },
            presence: { in: CONFIG_TYPES }

  class << self
    def create_for(object, clone=nil)
      create(
        object_type: object.class.to_s,
        object_id: object.id,
        config_type: SETTINGS,
        config: find_for(clone)&.config || defaults(object)
      )
    end

    def find_for(object)
      return nil unless object
      find_by(object_type: object.class.to_s, object_id: object.id, config_type: SETTINGS)
    end

    def config_for(object)
      defaults(object).merge(find_for(object)&.config || {})
    end

    def defaults(object)
      DEFAULT_CONFIG[object.class.to_s].stringify_keys
    end
  end
end
