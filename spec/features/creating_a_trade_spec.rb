require 'rails_helper'

RSpec.feature 'Creating a trade' do
  scenario 'with no customisation' do
    business = create(:business)
    portfolio = create(:portfolio, business: business)
    create(:user, business: business)

    page = PortfolioPage.new
    page.load(portfolio_id: portfolio.id)

    page.create_trade

    expect(Trade.count).to eq(1)
  end
end
