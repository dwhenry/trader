require 'rails_helper'

RSpec.feature 'Set a new user up' do
  scenario 'collect and create business and primary portfolio adn setup user roles' do
    user = create(:user, role: nil)
    with_user(user) do
      business_page = BusinessPage.new
      business_page.load

      page = NewBusinessPage.new
      expect(page).to be_displayed

      page.setup

      expect(business_page).to be_displayed

      # it creates the default roles for the business
      expect(Role.where(business_id: user.business_id).pluck(:name)).to include('admin', 'trader', 'backoffice')
    end
  end
end
