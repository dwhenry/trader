require 'rails_helper'

RSpec.feature 'Trade with simple custom string field' do
  scenario 'with no default' do
    business = create(:business)
    portfolio = create(:portfolio, business: business)
    fields = {
      description: FieldConfig.new(
        name: 'Description',
        type: 'string',
      )
    }
    create(:custom_config, object: portfolio, config_type: 'fields', config: fields.to_json)
    create(:security, business: business)
    user = create(:user, business: business)

    with_user(user) do
      page = PortfolioPage.new
      page.load(portfolio_id: portfolio.id)

      page.create_trade(description: 'Apples')

      expect(Trade.count).to eq(1)
      expect(Trade.first.custom_instance).to have_attributes(description: 'Apples')
    end
  end

  class FieldConfig < Struct.new(:name, :type)
    def as_json(*)
      {
        name: name,
        type: type,
      }
    end
  end
end
