require 'rails_helper'

RSpec.feature 'Creating a trade' do
  scenario 'with no customisation' do
    business = create(:business)
    portfolio = create(:portfolio, business: business)
    security = create(:security)
    user = create(:user, business: business)

    with_user(user) do
      page = PortfolioPage.new
      page.load(portfolio_id: portfolio.id)

      page.create_trade

      expect(Trade.count).to eq(1)

      trade = Trade.last
      expect(Event.last).to have_attributes(
        trade_uid: trade.uid,
        portfolio_id: portfolio.id,
        event_type: 'create',
        user_id: user.id,
        object_type: 'Trade',
        object_id: trade.id,
        parent_id: nil,
        details: {
          'uid' => ['', trade.uid],
          'date' => [nil, '2017-01-05'],
          'price' => [nil, '12.34'],
          'currency' => [nil, 'AUD'],
          'quantity' => [nil, 100],
          'security_id' => [nil, security.id],
          'portfolio_id' => [nil, portfolio.id]
        }
      )
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
