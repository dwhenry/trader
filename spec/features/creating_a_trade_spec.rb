require 'rails_helper'

RSpec.feature 'Creating a trade' do
  scenario 'Can create a generic trade with no customisation' do
    business = create(:business)
    account = create(:account, business: business)
    create(:user, bussiness: business)

    page = Page::Account.new
    page.load(account: account)

    page.create_trade

    expect(Trade,count).to eq(1)
  end
end
