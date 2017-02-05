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
      portfolio_create_event_id = Event.find_by(event_type: 'create', owner_type: 'Portfolio').id
      portfolio_edit_event_id = Event.find_by(event_type: 'edit', owner_type: 'Portfolio').id
      portfolio_config_id = CustomConfig.find_for(portfolio).id

      expect(Event.pluck(:portfolio_uid, :event_type, :user_id, :owner_type, :owner_id, :parent_id)).to eq(
        [
          [portfolio.uid, 'create', user.id, 'Portfolio', portfolio.id, nil],
          [portfolio.uid, 'create', user.id, 'CustomConfig', portfolio_config_id, portfolio_create_event_id],
          [portfolio.uid, 'edit', user.id, 'Portfolio', portfolio.id, nil],
          [portfolio.uid, 'edit', user.id, 'CustomConfig', portfolio_config_id, portfolio_edit_event_id],
        ],
      )

      expect(Event.pluck(:event_type, :owner_type, :details)).to eq(
        [
          ['create', 'Portfolio', { 'name' => [nil, 'Bobs trades'], 'business_id' => [nil, business.id] }],
          [
            'create',
            'CustomConfig',
            'allow_negative_positions' => [nil, 'no'],
          ],
          ['edit', 'Portfolio', { 'name' => ['Bobs trades', 'Dans trades'] }],
          [
            'edit',
            'CustomConfig',
            'allow_negative_positions' => %w(no yes),
          ],
        ],
      )
    end
  end
end
