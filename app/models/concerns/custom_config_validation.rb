require 'active_support/concern'

module CustomConfigValidation
  extend ActiveSupport::Concern

  included do
    validate :_custom_config_validation
  end

  def _custom_config_validation
    validatables.each do |validatable|
      custom_config = CustomConfig.find_for(validatable)
      next unless custom_config
      custom_config.config.each do |name, value|
        validator = BaseValidator.get(name)
        validator&.validate(self, value)
      end
    end
  end

  class BaseValidator
    def self.get(key)
      return unless CustomConfigValidation.const_defined?("#{key.camelcase}Validator")
      CustomConfigValidation.const_get("#{key.camelcase}Validator")
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
      return if current_position >= adjusted_trade_quantity
      @object.errors.add(:quantity, 'Generates a negative position')
    end

    def current_position
      Trade.where(portfolio_id: @object.portfolio_id, security_id: @object.security_id).sum(:quantity)
    end

    def adjusted_trade_quantity
      # TODO: take into account edits once they are implemented.
      @object.quantity.abs
    end
  end
end
