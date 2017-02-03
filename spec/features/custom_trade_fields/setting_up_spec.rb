require 'rails_helper'

RSpec.feature 'Custom config field' do
  scenario 'can created a text field' do
    new_field_config do |page, portfolio|
      config_page = ConfigFieldPage.new
      config_page.add_fruit_field

      expect(page.portfolios.first.fields.count).to eq(1)

      expect(CustomConfig.fields_for(portfolio)).to have_attributes(
        config_type: 'fields',
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
        object_type: 'CustomConfig',
        parent_id: nil,
        portfolio_id: portfolio.id,
        trade_uid: nil,
      )
    end
  end

  scenario 'adding a field to a portfolio with trades will generate a new portfolio version' do
    pending
    new_field_config do |page, portfolio|
      create(:trade, portfolio: portfolio)
      config_page = ConfigFieldPage.new
      config_page.add_fruit_field

      expect(page.portfolios.first.fields.count).to eq(1)

      expect(Portfolio.count).to eq(2)
      expect(Portfolio.uniq.pluck(:uid).count).to eq(1)
    end
  end

  def new_field_config
    business = create(:business, :with_config)
    portfolio = create(:portfolio, :with_config, business: business)
    user = create(:user, business: business)

    with_user(user) do
      page = ConfigPage.new
      page.load

      # can update the user name
      page.tab("portfolio's")
      page.portfolios.first.add_field.click

      yield page, portfolio
    end
  end
end
