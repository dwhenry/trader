require 'rails_helper'

RSpec.feature 'Editing a trade' do
  scenario 'works as expected' do
    business = create(:business)
    portfolio = create(:portfolio, business: business)
    security = create(:security, business: business)
    trade = create(:trade, portfolio: portfolio, security: security)
    user = create(:user, business: business)

    with_user(user) do
      page = PortfolioPage.new
      page.load(portfolio_id: portfolio.id)

      page.edit_trade(trade.uid, quantity: 200)

      expect(Trade.count).to eq(3)
      expect(Trade.current.count).to eq(1)
      expect(Trade.sum(:quantity)).to eq(200)

      trade = Trade.current.first
      expect(Event.count).to eq(2)
      trade_event = Event.find_by(owner_type: 'Trade', event_type: 'edit')
      expect(trade_event).to have_attributes(
        trade_uid: trade.uid,
        portfolio_uid: portfolio.uid,
        user_id: user.id,
        owner_id: trade.id,
        parent_id: nil,
        details: { 'quantity' => [10, 200] },
      )
      backoffice_event = Event.find_by(owner_type: 'Backoffice', event_type: 'edit')
      expect(backoffice_event).to have_attributes(
        trade_uid: trade.uid,
        portfolio_uid: portfolio.uid,
        user_id: user.id,
        owner_id: trade.backoffice.id,
        parent_id: trade_event.id,
        details: { 'trade_version' => [1, 3] },
      )
      expect(Trade.pluck(:version)).to include(1, 2, 3)
    end
  end

  scenario 'can update a backoffice field' do
    business = create(:business)
    portfolio = create(:portfolio, business: business)
    security = create(:security, business: business)
    trade = create(:trade, portfolio: portfolio, security: security)
    user = create(:user, business: business)

    with_user(user) do
      page = PortfolioPage.new
      page.load(portfolio_id: portfolio.id)

      page.edit_trade(trade.uid, state: 'Settled')

      expect(Trade.count).to eq(1)
      expect(Backoffice.count).to eq(2)
      expect(Trade.first.backoffice.state).to eq('Settled')

      trade = Trade.current.first
      expect(Event.count).to eq(1)
      event = Event.find_by(owner_type: 'Backoffice', event_type: 'edit')
      expect(event).to have_attributes(
        trade_uid: trade.uid,
        portfolio_uid: portfolio.uid,
        user_id: user.id,
        owner_id: trade.backoffice.id,
        parent_id: nil,
        details: { 'state' => %w(Pending Settled) },
      )
    end
  end

  scenario "can't edit both trade and backoffice record" do
    business = create(:business)
    portfolio = create(:portfolio, business: business)
    security = create(:security, business: business)
    trade = create(:trade, portfolio: portfolio, security: security)
    user = create(:user, business: business)

    with_user(user) do
      page = PortfolioPage.new
      page.load(portfolio_id: portfolio.id)

      page.edit_trade(trade.uid, quantity: 200, state: 'Settled')

      expect(page).to have_content('Unable to update multiple objects')
    end
  end
end
