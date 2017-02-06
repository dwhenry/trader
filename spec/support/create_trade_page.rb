module CreateTradePage
  def create_trade_page(config_fields)
    business = create(:business)
    portfolio = create(:portfolio, business: business)
    create(:security, business: business)
    user = create(:user, business: business)

    create(:custom_config, owner: portfolio, config_type: 'fields', config: config_fields.as_json)

    with_user(user) do
      page = PortfolioPage.new
      page.load(portfolio_id: portfolio.id)

      yield(page)
    end
  end
end

RSpec.configure do |config|
  config.include CreateTradePage
end
