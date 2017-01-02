class UserSetup
  include ActiveModel::Model

  STEPS = %w(naming business portfolio).freeze
  FIELDS = [:business_name, :portfolio_name, :business, :portfolio].freeze
  attr_accessor *FIELDS

  def initialize(params, step = nil)
    @step = step
    super(params)
  end

  def business=(params)
    @business = params&.map { |p| ConfigField.new(p) }
  end

  def portfolio=(params)
    @portfolio = params&.map { |p| ConfigField.new(p) }
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
        business: (business || []).map(&:serialize),
        portfolio: (portfolio || []).map(&:serialize),
      }
    }
  end

  def save(current_user)
    ApplicationRecord.transaction do
      new_business = Business.create!(name: business_name)
      new_portfolio = Portfolio.create!(business: new_business, name: portfolio_name)

      CustomConfig.create!(object_type: 'Business', object_id: new_business.id, config: (business || []).map(&:serialize))
      CustomConfig.create!(object_type: 'Portfolio', object_id: new_portfolio.id, config: (portfolio || []).map(&:serialize))

      current_user.update!(business_id: new_business.id)
    end
  end

  private

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