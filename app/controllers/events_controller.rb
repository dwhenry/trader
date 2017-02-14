class EventsController < ApplicationController
  def index
    trade = policy_scope(Trade.current).find_by(uid: params[:trade_uid])
    portfolio = trade.portfolio || policy_scope(Portfolio).find_by(uid: params[:portfolio_uid])
    business = portfolio.business || current_user.business
    authorize trade || portfolio || business, :event?

    criteria = {
      parent_id: nil,
      trade_uid: [nil, trade.uid].uniq,
      portfolio_uid: [nil, portfolio.uid].uniq,
      business_id: business.id,
    }

    @events = Event.where(criteria).includes(:children).last_n(10)

    request.xhr? && render('index', layout: false)
  end
end
