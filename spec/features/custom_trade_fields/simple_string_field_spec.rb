require 'rails_helper'

RSpec.feature 'Trade with simple custom string field' do
  scenario 'with no default' do
    fields = {
      description: FieldConfig.new(
        name: 'Description',
        type: 'string',
      ),
    }

    new_trade(fields) do |page|
      page.create_trade(description: 'No default')

      expect(Trade.count).to eq(1)
      expect(Trade.first.custom_instance).to have_attributes(description: 'No default')

      trade_event = Event.find_by(object_type: 'Trade', event_type: 'create')
      expect(trade_event).to have_attributes(
        details: {
          'date' => [nil, Time.zone.today.strftime('%Y-%m-%d')],
          'price' => [nil, '12.34'],
          'currency' => [nil, 'AUD'],
          'quantity' => [nil, 100],
          'security_id' => [nil, trade_event.trade.security_id],
          'portfolio_id' => [nil, trade_event.trade.portfolio_id],
          'description' => [nil, 'No default'],
        },
      )
    end
  end

  scenario 'with a default value' do
    fields = {
      fruit: FieldConfig.new(
        name: 'Fruit',
        type: 'string',
        default: 'Bananas',
      ),
    }

    new_trade(fields) do |page|
      page.create_trade

      expect(Trade.count).to eq(1)
      expect(Trade.first.custom_instance).to have_attributes(fruit: 'Bananas')
    end
  end

  scenario 'can override default value' do
    fields = {
      animals: FieldConfig.new(
        name: 'Animal',
        type: 'string',
        default: 'Bear',
      ),
    }

    new_trade(fields) do |page|
      page.create_trade(animals: 'Override default')

      expect(Trade.count).to eq(1)
      expect(Trade.first.custom_instance).to have_attributes(animals: 'Override default')
    end
  end

  class FieldConfig < OpenStruct
    def as_json(*)
      {
        name: name,
        type: type,
        default: default,
      }
    end
  end

  def new_trade(config_fields)
    business = create(:business)
    portfolio = create(:portfolio, business: business)
    create(:security, business: business)
    user = create(:user, business: business)

    create(:custom_config, object: portfolio, config_type: 'fields', config: config_fields.as_json)

    with_user(user) do
      page = PortfolioPage.new
      page.load(portfolio_id: portfolio.id)

      yield(page)
    end
  end
end
