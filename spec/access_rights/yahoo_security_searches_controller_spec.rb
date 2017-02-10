require 'rails_helper'

RSpec.describe YahooSecuritySearchesController, type: :controller do
  let(:role) { Role.create(name: 'yahoo_search') }
  let(:user) { create(:user, business: create(:business), role: role) }
  before do
    allow(controller).to receive(:current_user).and_return(user)
  end

  context '#show' do
    it 'allow when user has `follow_security` permissions' do
      Permission.create(role: role, name: Role::FOLLOW_SECURITY)
      get 'show'
      expect(response).to be_success
    end

    it 'disallows when user does not has `follow_security` permissions' do
      get 'show'
      expect(response).to redirect_to(root_path)
    end
  end
end
