require 'rails_helper'

RSpec.feature 'Trade with simple custom string field' do
  scenario 'with no default' do
    fields = FieldForm.new(
      name: 'Description',
      type: 'string',
    )

    create_trade_page(fields) do |page|
      page.create_trade(description: 'No default')

      expect(Trade.count).to eq(1)
      expect(Trade.first.custom_instance).to have_attributes(description: 'No default')

      trade_event = Event.find_by(owner_type: 'Trade', event_type: 'create')
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
    fields = FieldForm.new(
      name: 'Fruit',
      type: 'string',
      default: 'Bananas',
    )

    create_trade_page(fields) do |page|
      page.create_trade

      expect(Trade.count).to eq(1)
      expect(Trade.first.custom_instance).to have_attributes(fruit: 'Bananas')
    end
  end

  scenario 'can override default value' do
    fields = FieldForm.new(
      name: 'Animal',
      type: 'string',
      default: 'Bear',
    )

    create_trade_page(fields) do |page|
      page.create_trade(animal: 'Override default')

      expect(Trade.count).to eq(1)
      expect(Trade.first.custom_instance).to have_attributes(animal: 'Override default')
    end
  end
end
