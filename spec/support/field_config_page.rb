module FieldConfigPage
  def create_field_config_page(field_config = nil)
    navigate_to_field_config_page(field_config) do |page, portfolio|
      page.portfolios.first.add_field.click

      yield page, portfolio
    end
  end

  def navigate_to_field_config_page(field_config = nil) # rubocop:disable Metrics/MethodLength
    business = create(:business)
    portfolio = create(:portfolio, :with_config, business: business)

    if field_config
      create(
        :custom_config,
        owner_id: portfolio.id,
        owner_type: 'Portfolio',
        config_type: CustomConfig::TRADE_FIELDS,
        config: field_config,
      )
    end

    user = create(:user, business: business)

    with_user(user) do
      page = ConfigPage.new
      page.load

      # can update the user name
      page.tab('portfolios')

      yield page, portfolio
    end
  end
end

RSpec.configure do |config|
  config.include FieldConfigPage
end
