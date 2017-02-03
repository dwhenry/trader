class CustomConfig < ApplicationRecord
  CONFIG_TYPES = [
    SETTINGS = 'settings'.freeze,
    FIELDS = 'fields'.freeze,
  ].freeze

  DEFAULT_CONFIG = {
    'Business' => { reporting_currency: 'USD' },
    'Portfolio' => { allow_negative_positions: 'no' },
  }.freeze

  CONFIG_OPTIONS = {
    allow_negative_positions: { type: :radio, options: %w(yes no) },
    reporting_currency: { type: :select, options: %w(AUD USD) },
  }.freeze

  belongs_to :object, polymorphic: true
  validates :config_type,
            uniqueness: { scope: [:object_type, :object_id] },
            inclusion: { in: CONFIG_TYPES }

  class << self
    def fields_for(object)
      return nil unless object
      find_by(object_type: object.class.to_s, object_id: object.id, config_type: FIELDS)
    end

    def find_for(object)
      return nil unless object
      find_by(object_type: object.class.to_s, object_id: object.id, config_type: SETTINGS)
    end

    def find_or_initialize_for(object, config_type: SETTINGS)
      return nil unless object
      find_or_initialize_by(object_type: object.class.to_s, object_id: object.id, config_type: config_type)
    end

    def defaults(object)
      DEFAULT_CONFIG[object.class.to_s].stringify_keys
    end
  end
end
