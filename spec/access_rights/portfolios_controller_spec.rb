require 'rails_helper'

RSpec.describe PortfoliosController, type: :controller do
  context 'create' do
    let(:user) { create(:user, business: create(:business), role: role) }
    let(:role) { Role.new(name: 'portfolio') }

    before do
      allow(controller).to receive(:current_user).and_return(user)
    end

    it 'allows with portfolio_creation' do
      role.permissions.build(name: Role::CREATE_PORTFOLIO)
      post 'create', params: { portfolio: { name: '' } }
      expect(response).to be_success
    end

    it 'disallows without portfolio_creation' do
      expect { post 'create', params: { name: 'faker' } }.to raise_error(Pundit::NotAuthorizedError)
    end
  end
end
