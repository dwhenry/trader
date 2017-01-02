require 'rails_helper'

RSpec.feature 'Set a new user up' do
  scenario 'collect and create buisness and primary portfolio' do
    with_user(create(:user)) do

      business_page = BusinessPage.new
      business_page.load

      expect(business_page).not_to be_displayed

      page = UserSetupPage.new
      expect(page).to be_displayed

      page.setup

      expect(business_page).to be_displayed
    end
  end
end
