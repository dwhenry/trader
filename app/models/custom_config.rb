class CustomConfig < ApplicationRecord
  CONFIG_TYPES = [
    SETTINGS = 'settings'.freeze,
    TRADE_FIELDS = 'trade_fields'.freeze,
    BACKOFFICE_FIELDS = 'backoffice_fields'.freeze,
  ].freeze

  DEFAULT_CONFIG = {
    'Business' => { },
    'Portfolio' => { allow_negative_positions: 'no' },
  }.freeze

  CONFIG_OPTIONS = {
    allow_negative_positions: { type: :radio, options: %w(yes no) },
  }.freeze

  belongs_to :owner, polymorphic: true
  validates :config_type,
            uniqueness: { scope: [:owner_type, :owner_id] },
            inclusion: { in: CONFIG_TYPES }
  validates_with ActiveRecord::Validations::AssociatedValidator, attributes: [:config_instance]

  def config_instance
    @config_instance ||= OpenModel.new(config)
  end

  class << self
    def fields_for(object)
      find_for(object, config_type: TRADE_FIELDS)
    end

    def find_for(object, config_type: SETTINGS)
      return nil unless object
      find_by(owner_type: object.class.to_s, owner_id: object.id, config_type: config_type)
    end

    def find_or_initialize_for(owner, config_type: SETTINGS)
      return nil unless owner
      find_or_initialize_by(owner_type: owner.class.to_s, owner_id: owner.id, config_type: config_type)
    end

    def defaults(object)
      DEFAULT_CONFIG[object.class.to_s].stringify_keys
    end
  end
end
