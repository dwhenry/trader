require 'rails_helper'

RSpec.feature 'Successfully logs events' do
  scenario 'creation and editing of a portfolio' do
    business = create(:business, :with_config)
    create(:portfolio, :with_config, business: business)
    user = create(:user, business: business)


    with_user(user) do
      page = ConfigPage.new
      page.load

      # can update the portfolio and portfolio config
      page.tab("portfolio's")
      page.new_portfolio_name.set('Bobs trades')
      page.add.click

      portfolio_section = page.portfolios.detect { |p| p.portfolio_name.value == 'Bobs trades' }
      portfolio_section.portfolio_name.set('Dans trades')
      portfolio_section.allow_negative_positions.set true
      portfolio_section.save.click

      portfolio = Portfolio.find_by(name: 'Dans trades')
      expect(Event.pluck(:portfolio_id, :event_type, :user_id, :object_type, :parent_id)).to eq(
        [
          [portfolio.id, 'create', user.id, 'Portfolio', nil],
          [portfolio.id, 'create', user.id, 'CustomConfig', Event.find_by(event_type: 'create', object_type: 'Portfolio').id],
          [portfolio.id, 'edit', user.id, 'Portfolio', nil],
          [portfolio.id, 'edit', user.id, 'CustomConfig', Event.find_by(event_type: 'edit', object_type: 'Portfolio').id],
        ]
      )
    end

  end
end
