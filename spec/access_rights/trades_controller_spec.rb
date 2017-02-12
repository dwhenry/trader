require 'rails_helper'

RSpec.describe TradesController, type: :controller do
  let(:role) { Role.create(name: 'yahoo_search') }
  let(:user) { create(:user, business: create(:business), role: role) }
  before do
    allow(controller).to receive(:current_user).and_return(user)
  end

  context '#new' do
    it 'allows with create_trade and for portfolio owned by user business' do
      portfolio = create(:portfolio, business: user.business)
      role.update(permissions: Role::CREATE_TRADE)
      get 'new', params: { trade: { portfolio_id: portfolio.id } }
      expect(response).to be_success
    end

    it 'disallow with create_trade and for portfolio not owned by user business' do
      portfolio = create(:portfolio, business: create(:business))
      role.update(permissions: Role::CREATE_TRADE)
      get 'new', params: { trade: { portfolio_id: portfolio.id } }
      expect(response).to redirect_to(root_path)
    end

    it 'disallows without create_trade' do
      portfolio = create(:portfolio, business: user.business)
      get 'new', params: { trade: { portfolio_id: portfolio.id } }
      expect(response).to redirect_to(root_path)
    end
  end

  context '#create' do
    it 'allows with create_trade and for portfolio owned by user business' do
      portfolio = create(:portfolio, business: user.business)
      role.update(permissions: Role::CREATE_TRADE)
      post 'create', params: { trade: { portfolio_id: portfolio.id } }
      expect(response).to be_success
    end

    it 'disallow with create_trade and for portfolio not owned by user business' do
      portfolio = create(:portfolio, business: create(:business))
      role.update(permissions: Role::CREATE_TRADE)
      post 'create', params: { trade: { portfolio_id: portfolio.id } }
      expect(response).to redirect_to(root_path)
    end

    it 'disallows without create_trade' do
      portfolio = create(:portfolio, business: user.business)
      post 'create', params: { trade: { portfolio_id: portfolio.id } }
      expect(response).to redirect_to(root_path)
    end
  end

  context '#edit' do
    it 'allows with edit_trade and for portfolio owned by user business' do
      portfolio = create(:portfolio, business: user.business)
      trade = create(:trade, portfolio: portfolio, security: create(:security, business: portfolio.business))
      role.update(permissions: Role::EDIT_TRADE)
      get 'edit', params: { id: trade.uid }
      expect(response).to be_success
    end

    it 'disallow with edit_trade and for portfolio not owned by user business' do
      portfolio = create(:portfolio, business: create(:business))
      trade = create(:trade, portfolio: portfolio, security: create(:security, business: portfolio.business))
      role.update(permissions: Role::EDIT_TRADE)
      get 'edit', params: { id: trade.uid }
      expect(response).to redirect_to(root_path)
    end

    it 'allow with edit_back_office and for portfolio owned by user business' do
      portfolio = create(:portfolio, business: user.business)
      trade = create(:trade, portfolio: portfolio, security: create(:security, business: portfolio.business))
      role.update(permissions: Role::EDIT_BACKOFFICE)
      get 'edit', params: { id: trade.uid }
      expect(response).to be_success
    end

    it 'disallow with edit_back_office and for portfolio not owned by user business' do
      portfolio = create(:portfolio, business: create(:business))
      trade = create(:trade, portfolio: portfolio, security: create(:security, business: portfolio.business))
      role.update(permissions: Role::EDIT_BACKOFFICE)
      get 'edit', params: { id: trade.uid }
      expect(response).to redirect_to(root_path)
    end

    it 'disallows without edit_trade or edit_back_office' do
      portfolio = create(:portfolio, business: user.business)
      trade = create(:trade, portfolio: portfolio, security: create(:security, business: portfolio.business))
      get 'edit', params: { id: trade.uid }
      expect(response).to redirect_to(root_path)
    end
  end

  context '#update' do
    context 'with change to trade fields' do
      it 'allows with edit_trade and for portfolio owned by user business' do
        portfolio = create(:portfolio, business: user.business)
        trade = create(:trade, :with_backoffice, trade_params(portfolio))
        role.update(permissions: Role::EDIT_TRADE)
        patch 'update', params: { id: trade.uid, trade: { currency: 'USD' }, backoffice: { state: 'Pending' } }
        expect(response).to redirect_to(edit_trade_path(trade.uid))
      end

      it 'disallows with edit_trade and for portfolio not owned by user business' do
        portfolio = create(:portfolio, business: create(:business))
        trade = create(:trade, :with_backoffice, trade_params(portfolio))
        role.update(permissions: Role::EDIT_TRADE)
        patch 'update', params: { id: trade.uid, trade: { currency: 'USD' }, backoffice: { state: 'Pending' } }
        expect(response).to redirect_to(root_path)
      end

      it 'disallows with edit_backoffice and for portfolio owned by user business' do
        portfolio = create(:portfolio, business: user.business)
        trade = create(:trade, :with_backoffice, trade_params(portfolio))
        role.update(permissions: Role::EDIT_BACKOFFICE)
        patch 'update', params: { id: trade.uid, trade: { currency: 'USD' }, backoffice: { state: 'Pending' } }
        expect(response).to redirect_to(root_path)
      end

      it 'disallows without edit_trade' do
        portfolio = create(:portfolio, business: user.business)
        trade = create(:trade, :with_backoffice, trade_params(portfolio))
        patch 'update', params: { id: trade.uid, trade: { currency: 'USD' }, backoffice: { state: 'Pending' } }
        expect(response).to redirect_to(root_path)
      end
    end

    context 'with change to backoffice fields' do
      it 'allows with edit_backoffice and for portfolio owned by user business' do
        portfolio = create(:portfolio, business: user.business)
        trade = create(:trade, :with_backoffice, trade_params(portfolio))
        role.update(permissions: Role::EDIT_BACKOFFICE)
        patch 'update', params: { id: trade.uid, trade: { currency: 'AUD' }, backoffice: { state: 'Started' } }
        expect(response).to redirect_to(edit_trade_path(trade.uid))
      end

      it 'disallows with edit_backoffice and for portfolio not owned by user business' do
        portfolio = create(:portfolio, business: create(:business))
        trade = create(:trade, :with_backoffice, trade_params(portfolio))
        role.update(permissions: Role::EDIT_BACKOFFICE)
        patch 'update', params: { id: trade.uid, trade: { currency: 'AUD' }, backoffice: { state: 'Started' } }
        expect(response).to redirect_to(root_path)
      end

      it 'disallows with edit_trade and for portfolio owned by user business' do
        portfolio = create(:portfolio, business: user.business)
        trade = create(:trade, :with_backoffice, trade_params(portfolio))
        role.update(permissions: Role::EDIT_TRADE)
        patch 'update', params: { id: trade.uid, trade: { currency: 'AUD' }, backoffice: { state: 'Started' } }
        expect(response).to redirect_to(root_path)
      end

      it 'disallows without edit_backoffice' do
        portfolio = create(:portfolio, business: user.business)
        trade = create(:trade, :with_backoffice, trade_params(portfolio))
        patch 'update', params: { id: trade.uid, trade: { currency: 'AUD' }, backoffice: { state: 'Started' } }
        expect(response).to redirect_to(root_path)
      end
    end

    def trade_params(portfolio)
      { portfolio: portfolio, security: create(:security, business: portfolio.business) }
    end
  end
end
