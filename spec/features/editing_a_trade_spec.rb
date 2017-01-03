require 'rails_helper'

RSpec.feature 'Editing a trade' do
  scenario 'works as expected' do
    business = create(:business)
    portfolio = create(:portfolio, business: business)
    security = create(:security)
    trade = create(:trade, portfolio: portfolio, security: security)

    with_user(create(:user, business: business)) do
      page = PortfolioPage.new
      page.load(portfolio_id: portfolio.id)

      page.edit_trade(trade.uid, quantity: 200)

      expect(Trade.count).to eq(3)
      expect(Trade.current.count).to eq(1)
      expect(Trade.sum(:quantity)).to eq(200)
    end
  end

  scenario 'can update a backoffice field' do
    business = create(:business)
    portfolio = create(:portfolio, business: business)
    security = create(:security)
    trade = create(:trade, portfolio: portfolio, security: security)

    with_user(create(:user, business: business)) do
      page = PortfolioPage.new
      page.load(portfolio_id: portfolio.id)

      page.edit_trade(trade.uid, state: 'Settled')

      expect(Trade.count).to eq(1)
      expect(Backoffice.count).to eq(2)
      expect(Trade.first.backoffice.state).to eq('Settled')
    end
  end
end
