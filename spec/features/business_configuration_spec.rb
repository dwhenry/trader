require 'rails_helper'

RSpec.feature 'Business configuration' do
  scenario 'can update settings' do
    business = create(:business, :with_config)
    portfolio = create(:portfolio, :with_config, business: business)
    user = create(:user, business: business)

    with_user(user) do
      page = ConfigPage.new
      page.load

      # can update the business and business config
      page.tab(:business)
      page.business_name.set 'New name'
      page.reporting_currency.select 'AUD'
      page.save.click

      business.reload
      expect(business.name).to eq('New name')
      business_config = CustomConfig.find_for(business).config
      expect(business_config['reporting_currency']).to eq('AUD')

      # can update the user name
      page.tab(:user)
      page.user_name.set 'Jim Bob'
      page.save.click

      page.emails.set('jim@bob.com, jack@been.stalk')
      page.add.click

      user.reload
      expect(user.name).to eq('Jim Bob')

      expect(User.where(business: business).pluck(:email)).to include('jim@bob.com', 'jack@been.stalk')

      # can update the portfolio and portfolio config
      page.tab("portfolio's")
      page.portfolio_name.set('Bobs trades')
      page.allow_negative_positions.set true
      page.save.click

      portfolio.reload
      expect(portfolio.name).to eq('Bobs trades')
      portfolio_config = CustomConfig.find_for(portfolio).config
      expect(portfolio_config['allow_negative_positions']).to eq('yes')
    end
  end
end
