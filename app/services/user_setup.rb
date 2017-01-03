class UserSetup
  include ActiveModel::Model

  STEPS = %w(naming business portfolio).freeze
  FIELDS = [:business_name, :portfolio_name, :business].freeze
  attr_accessor *FIELDS

  def initialize(params, step = nil)
    @step = step
    super(params)
  end

  def business_configs=(params)
    @business_configs ||= params&.map { |p| ConfigField.new(p) }
  end

  def business_configs
    @business_configs || [UserSetup::ConfigField.new(name: :allow_negative_positions)]
  end

  def portfolio_configs=(params)
    @portfolio_configs ||= params&.map { |p| ConfigField.new(p) }
  end

  def portfolio_configs
    @portfolio_configs || [UserSetup::ConfigField.new(name: :allow_negative_positions)]
  end

  def complete?
    @step == STEPS.last
  end

  def serialize
    {
      step: step,
      user_setup: {
        business_name: business_name,
        portfolio_name: portfolio_name,
        business_configs: obj_serialize(business_configs),
        portfolio_configs: obj_serialize(portfolio_configs),
      },
    }
  end

  def save(current_user) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    ApplicationRecord.transaction do
      begin
        @business ||= Business.create!(name: business_name)
        portfolio = Portfolio.create!(business: business, name: portfolio_name)

        CustomConfig.create!(
          object_type: 'Business',
          object_id: @business.id,
          config: business_configs.map(&:serialize),
        )
        CustomConfig.create!(
          object_type: 'Portfolio',
          object_id: portfolio.id,
          config: portfolio_configs.map(&:serialize),
        )

        current_user.update!(business_id: @business.id)
        return true
      rescue
        raise ActiveRecord::Rollback
      end
    end
    false
  end

  private

  def obj_serialize(object)
    (object || []).map(&:serialize)
  end

  def step
    pos = STEPS.index(@step) || 0
    STEPS[pos + 1] || STEPS.last
  end

  class ConfigField
    include ActiveModel::Model

    attr_accessor :name, :value

    def serialize
      {
        name: name,
        value: value,
      }
    end
  end
end
