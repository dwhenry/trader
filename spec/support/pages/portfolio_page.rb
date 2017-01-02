class PortfolioPage < SitePrism::Page
  set_url '/portfolios{/portfolio_id}'

  element :book_trade, '.t-book-trade'
  element :pending_trades, '.t-pending-trades'

  sections :trades, '.t-trade' do
    element :uid, '.t-trade-uid'
  end

  def create_trade(custom = {})
    book_trade.click

    page = NewTradePage.new
    page.fill_in_trade(custom)
    page.save
  end

  def edit_trade(trade_uid, changes = {})
    pending_trades.click

    trade = trades.detect { |trade| trade.uid.text == trade_uid }
    trade.uid.click

    page = EditTradePage.new
    page.fill_in_trade(changes)
    page.save
  end
end
