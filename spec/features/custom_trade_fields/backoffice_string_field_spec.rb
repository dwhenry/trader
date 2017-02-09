require 'rails_helper'

RSpec.feature 'Trade with backoffice custom string field' do
  scenario 'with no default' do
    fields = FieldForm.new(
      name: 'Description',
      type: 'string',
    )

    create_trade_page(fields, config_type: CustomConfig::BACKOFFICE_FIELDS) do |page|
      page.create_trade
      page.edit_trade(Trade.first.uid, description: 'No default')

      expect(Trade.count).to eq(1)
      expect(Trade.first.backoffice.custom_instance).to have_attributes(description: 'No default')

      trade_event = Event.find_by(owner_type: 'Trade', event_type: 'create')
      expect(trade_event).to have_attributes(
        details: {
          'date' => [nil, Time.zone.today.strftime('%Y-%m-%d')],
          'price' => [nil, '12.34'],
          'currency' => [nil, 'AUD'],
          'quantity' => [nil, 100],
          'security_id' => [nil, trade_event.trade.security_id],
          'portfolio_id' => [nil, trade_event.trade.portfolio_id],
        },
      )

      backoffice_event = Event.find_by(owner_type: 'Backoffice', event_type: 'edit')
      expect(backoffice_event).to have_attributes(
        details: {
          'description' => [nil, 'No default'],
        },
      )
    end
  end
end
