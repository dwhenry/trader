require 'rails_helper'

RSpec.describe PortfoliosController, type: :controller do
  let(:role) { Role.new(name: 'portfolio') }
  let(:user) { create(:user, business: create(:business), role: role) }
  before do
    allow(controller).to receive(:current_user).and_return(user)
  end

  context '#create' do
    it 'allows with portfolio_creation' do
      role.update(permissions: Role::CREATE_PORTFOLIO)
      post 'create', params: { portfolio: { name: '' } }
      expect(response).to be_success
    end

    it 'disallows without portfolio_creation' do
      post 'create', params: { name: 'faker' }
      expect(response).to redirect_to(root_path)
    end
  end

  context '#show' do
    it 'allow when user owns portfolio' do
      portfolio = create(:portfolio, business: user.business)
      get 'show', params: { id: portfolio.id }
      expect(response).to be_success
    end

    it 'disallows when user does not own portfolio' do
      portfolio = create(:portfolio, business: create(:business))
      expect { get 'show', params: { id: portfolio.id } }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context '#update' do
    let(:params) { { portfolio: { name: 'jack' }, config: { allow_negative_positions: 'no' } } }

    it 'allows with portfolio_edit and user owns portfolio' do
      role.update(permissions: Role::EDIT_PORTFOLIO)
      portfolio = create(:portfolio, business: user.business)
      patch 'update', params: params.merge(id: portfolio.id)
      expect(response).to redirect_to(config_path(tab: 'portfolios', anchor: "portfolio-#{portfolio.id}"))
    end

    it 'allows without portfolio_edit and user owns portfolio' do
      portfolio = create(:portfolio, business: user.business)
      patch 'update', params: params.merge(id: portfolio.id)
      expect(response).to redirect_to(root_path)
    end

    it 'allows with portfolio_edit and user does not owns portfolio' do
      role.update(permissions: Role::EDIT_PORTFOLIO)
      portfolio = create(:portfolio, business: create(:business))
      patch 'update', params: params.merge(id: portfolio.id)
      expect(response).to redirect_to(root_path)
    end

    it 'disallow if not the current portfolio version' do
      role.update(permissions: Role::EDIT_PORTFOLIO)
      portfolio = create(:portfolio, business: user.business, current: false)
      expect do
        patch 'update', params: params.merge(id: portfolio.id)
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
