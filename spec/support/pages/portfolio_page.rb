class PortfolioPage < SitePrism::Page
  set_url '/portfolios{/portfolio_id}'

  element :book_trade, '.t-book-trade'

  def create_trade(custom = {})
    book_trade.click

    page = NewTradePage.new

    page.fill_in_trade(custom)

    page.save
  end
end
