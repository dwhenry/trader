require 'rails_helper'

RSpec.feature 'Custom config field' do
  scenario 'can created a text field on the backoffice table' do
    create_field_config_page do |page, portfolio|
      config_page = ConfigFieldPage.new
      config_page.add_fruit_field(CustomConfig::BACKOFFICE_FIELDS)

      expect(page.portfolios.first.fields.count).to eq(1)

      expect(CustomConfig.find_for(portfolio, config_type: CustomConfig::BACKOFFICE_FIELDS)).to have_attributes(
        config_type: CustomConfig::BACKOFFICE_FIELDS,
        config: {
          'fruit_field' => {
            'name' => 'Fruit field',
            'type' => 'string',
            'validations' => {
              'presence' => true,
            },
            'default' => 'apples',
          },
        },
      )
    end
  end
end
