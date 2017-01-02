require 'active_support/concern'

module CustomConfigValidation
  extend ActiveSupport::Concern

  included do
    validate :_custom_config_validation
  end

  def _custom_config_validation
    self.validatables.each do |validatable|
      configs = CustomConfig.where(object_type: validatable.class.to_s, object_id: [nil, validatable.id])
      configs.each do |config|
        config.config.each do |validation|
          validator = BaseValidator.get(validation['name'])
          validator&.validate(self, validation['value'])
        end
      end
    end
  end

  class BaseValidator
    def self.get(key)
      if CustomConfigValidation.const_defined?("#{key.camelcase}Validator")
        CustomConfigValidation.const_get("#{key.camelcase}Validator")
      end
    end
  end

  class AllowNegativePositionsValidator
    def self.validate(object, value)
      new(object).validate(value)
    end

    def initialize(object)
      @object = object
    end

    def validate(value)
      return if value == 'yes' || @object.quantity.positive?
      if current_position < adjusted_position
        @object.errors.add(:quantity, 'Generates a negative position')
      end
    end

    def current_position
      Trade.where(portfolio_id: @object.portfolio_id, security_id: @object.security_id).sum(:quantity)
    end

    def adjusted_position
      # TODO: take into account edits once they are implemented.
      @object.quantity.abs
    end
  end
end
