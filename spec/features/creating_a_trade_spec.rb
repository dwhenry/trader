require 'rails_helper'

RSpec.feature 'Creating a trade' do
  scenario 'with no customisation' do
    business = create(:business)
    portfolio = create(:portfolio, business: business)
    create(:security)

    with_user(create(:user, business: business)) do
      page = PortfolioPage.new
      page.load(portfolio_id: portfolio.id)

      page.create_trade

      expect(Trade.count).to eq(1)
    end
  end

  scenario 'when a sell trade' do
    business = create(:business)
    portfolio = create(:portfolio, business: business)
    create(:security)

    with_user(create(:user, business: business)) do
      page = PortfolioPage.new
      page.load(portfolio_id: portfolio.id)

      page.create_trade(direction: 'sell')

      expect(Trade.count).to eq(1)
      expect(Trade.first.quantity).to be_negative
    end
  end
end
