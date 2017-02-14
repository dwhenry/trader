require 'rails_helper'

RSpec.describe SecuritiesController, type: :controller do
  let(:role) { Role.create(name: 'yahoo_search') }
  let(:user) { create(:user, business: create(:business), role: role) }
  before do
    allow(controller).to receive(:current_user).and_return(user)
  end

  context '#create' do
    before do
      allow(YahooSearch).to receive(:find).and_return(
        [
          ['symbol', 'name', 'stock exchange'],
          ['TICK', 'My Ticker', 'ASX'],
        ],
      )
      allow(ImportPriceData).to receive(:perform_later)
    end

    it 'allow when user has `follow_security` permissions' do
      role.update(permissions: Role::FOLLOW_SECURITY)
      post 'create', params: { security: { ticker: 'TICK' } }
      expect(response).to redirect_to(security_path(Security.last))
    end

    it 'disallows when user does not has `follow_security` permissions' do
      post 'create', params: { security: { ticker: 'TICK' } }
      expect(response).to redirect_to(root_path)
    end
  end

  context '#show' do
    it 'allows with any permissions when users business owns the security' do
      security = create(:security, business: user.business)
      get 'show', params: { id: security.id }
      expect(response).to be_success
    end

    it 'allows when user business dose not owns the security' do
      security = create(:security, business: create(:business))
      expect { get 'show', params: { id: security.id } }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'redirects to the version of the security owned by the business if they own one' do
      security = create(:security, business: create(:business))
      create(:security, business: user.business, ticker: security.ticker)
      get 'show', params: { id: security.id }
      expect(response).to be_success
    end
  end
end
