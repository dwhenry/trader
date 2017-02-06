require 'rails_helper'

RSpec.feature 'Custom config field' do
  scenario 'can created a text field' do
    create_field_config_page do |page, portfolio|
      config_page = ConfigFieldPage.new
      config_page.add_fruit_field

      expect(page.portfolios.first.fields.count).to eq(1)

      expect(CustomConfig.fields_for(portfolio)).to have_attributes(
        config_type: CustomConfig::TRADE_FIELDS,
        config: {
          'fruit_field' => {
            'name' => 'Fruit field',
            'type' => 'string',
            'validations' => {
              'presence' => true,
            },
            'default' => 'apples',
          },
        },
      )

      expect(Event.last).to have_attributes(
        details: {
          'fruit_field' => [
            nil,
            {
              'name' => 'Fruit field',
              'type' => 'string',
              'default' => 'apples',
              'validations' => { 'presence' => true },
            },
          ],
        },
        event_type: 'create',
        owner_type: 'CustomConfig',
        parent_id: nil,
        portfolio_uid: portfolio.uid,
        trade_uid: nil,
      )
    end
  end

  scenario 'adding a field to a portfolio with trades will generate a new portfolio version' do
    create_field_config_page do |page, portfolio|
      security = create(:security, business: portfolio.business)
      create(:trade, portfolio: portfolio, security: security)

      config_page = ConfigFieldPage.new
      config_page.add_fruit_field

      expect(page.portfolios.first.fields.count).to eq(1)

      expect(Portfolio.unscope(:where).count).to eq(2)
      expect(Portfolio.unscope(:where).distinct.pluck(:uid).count).to eq(1)
      expect(Event.find_by(owner_type: 'Portfolio', event_type: 'edit')).to be_nil
    end
  end

  scenario 'edit a custom field with existing trades' do
    create_field_config_page(fruit_field: { name: 'Old fruit' }) do |page, portfolio|
      security = create(:security, business: portfolio.business)
      create(:trade, portfolio: portfolio, security: security)

      config_page = ConfigFieldPage.new
      config_page.add_fruit_field

      expect(page.portfolios.first.fields.count).to eq(1)

      event = Event.find_by(owner_type: 'CustomConfig', event_type: 'edit')
      expect(event).to have_attributes(
        details: {
          'fruit_field' => [
            { 'name' => 'Old fruit' },
            {
              'name' => 'Fruit field',
              'type' => 'string',
              'default' => 'apples',
              'validations' => { 'presence' => true },
            },
          ],
        },
      )
    end
  end
end
