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
    new_field_config do |page, portfolio|
      security = create(:security, business: portfolio.business)
      create(:trade, portfolio: portfolio, security: security)

      config_page = ConfigFieldPage.new
      config_page.add_fruit_field

      expect(page.portfolios.first.fields.count).to eq(1)

      expect(Portfolio.unscope(:where).count).to eq(2)
      expect(Portfolio.unscope(:where).distinct.pluck(:uid).count).to eq(1)
      expect(Event.find_by(object_type: 'Portfolio', event_type: 'edit')).to be_nil
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
