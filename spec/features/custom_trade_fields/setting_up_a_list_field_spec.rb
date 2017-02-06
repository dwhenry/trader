require 'rails_helper'

RSpec.feature 'Custom config field' do
  scenario 'can created a list field' do
    create_field_config_page do |page, portfolio|
      config_page = ConfigFieldPage.new
      config_page.add_animal_field

      expect(page.portfolios.first.fields.count).to eq(1)

      expect(CustomConfig.fields_for(portfolio)).to have_attributes(
        config_type: CustomConfig::TRADE_FIELDS,
        config: {
          'animal_field' => {
            'name' => 'Animal field',
            'type' => 'list',
            'validations' => {
              'presence' => true,
              'inclusion' => %w(bear pig goat),
            },
            'default' => 'bear',
            'values' => %w(bear pig goat),
          },
        },
      )
    end
  end

  scenario 'edit a custom field with existing trades' do
    create_field_config_page(animal_field: { name: 'Old animal', values: %w(bear goat) }) do |page, portfolio|
      security = create(:security, business: portfolio.business)
      create(:trade, portfolio: portfolio, security: security)

      config_page = ConfigFieldPage.new
      config_page.add_animal_field

      expect(page.portfolios.first.fields.count).to eq(1)

      event = Event.find_by(owner_type: 'CustomConfig', event_type: 'edit')
      expect(event).to have_attributes(
        details: {
          'animal_field' => [
            {
              'name' => 'Old animal',
              'values' => %w(bear goat),
            },

            {
              'name' => 'Animal field',
              'type' => 'list',
              'values' => %w(bear pig goat),
              'default' => 'bear',
              'validations' => {
                'presence' => true,
                'inclusion' => %w(bear pig goat),
              },
            },
          ],
        },
      )
    end
  end
end
