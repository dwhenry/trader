require 'rails_helper'

RSpec.feature 'Trade with list field' do
  scenario 'allows you to choose one of the options' do
    fields = {
      options: FieldForm.new(
        name: 'Options',
        type: 'list',
        values: %w(one two three),
      ),
    }

    create_trade_page(fields) do |page|
      page.create_trade(options: 'one')

      expect(Trade.count).to eq(1)
      expect(Trade.first.custom_instance).to have_attributes(options: 'one')
    end
  end
end
