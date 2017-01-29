require 'rails_helper'

RSpec.feature 'Custom config field' do
  scenario 'can created a text field' do
    business = create(:business, :with_config)
    portfolio = create(:portfolio, :with_config, business: business)
    user = create(:user, business: business)

    with_user(user) do
      page = ConfigPage.new
      page.load

      # can update the user name
      page.tab("portfolio's")
      page.portfolios.first.add_field.click

      config_page = ConfigFieldPage.new
      config_page.name.set('fruit field')
      config_page.type.select('text')
      config_page.validate_presence.set(true)
      config_page.default = 'apples'

      config_page.save

      expect(page.fields.count).to eq(1)
      expect(CustomConfig.fields_for(portfolio)).to have_attributes(
        config_type: 'fields',
        custom: {
          'fruit field' => {
            type: 'text',
            validations: {
              presence: true,
            },
            default: 'apples'
          }
        }
      )

      expect(Event.last).to have_attributes(

      )
    end
  end
end
