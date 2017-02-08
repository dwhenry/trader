require 'rails_helper'

RSpec.feature 'Custom config field' do
  scenario 'can delete a custom config field' do
    navigate_to_field_config_page(animal: { name: 'Animal' }, fruit: { name: 'Fruit' }) do |page, portfolio|
      expect(page.portfolios.first.fields.count).to eq(2)

      page.delete_field('Animal')

      expect(page.portfolios.first.fields.count).to eq(1)

      expect(CustomConfig.fields_for(portfolio)).to have_attributes(
        config_type: CustomConfig::TRADE_FIELDS,
        config: {
          'fruit' => {
            'name' => 'Fruit',
          },
        },
      )

      event = Event.find_by(owner_type: 'CustomConfig', event_type: 'edit')
      expect(event).to have_attributes(
        details: {
          'animal' => [
            {
              'name' => 'Animal',
            },
            nil,
          ],
        },
      )
    end
  end

  scenario 'can delete a custom config field when portfolio has existing trades' do
    navigate_to_field_config_page(animal: { name: 'Animal' }, fruit: { name: 'Fruit' }) do |page, portfolio|
      security = create(:security, business: portfolio.business)
      create(:trade, portfolio: portfolio, security: security)

      expect(page.portfolios.first.fields.count).to eq(2)

      page.delete_field('Animal')

      expect(page.portfolios.first.fields.count).to eq(1)
      expect(portfolio).not_to eq(Portfolio.find_by(uid: portfolio.uid))
    end
  end
end
