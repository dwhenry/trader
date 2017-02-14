class EventsController < ApplicationController
  def index
    authorize trade || portfolio || business, :event?

    @events = Event.where(event_criteria).includes(:children).order(created_at: :desc)

    request.xhr? && render('index', layout: false)
  end

  private

  def trade
    @trade ||= policy_scope(Trade.current).find_by(uid: params[:trade_uid])
  end

  def portfolio
    @portfolio ||= trade.portfolio || policy_scope(Portfolio).find_by(uid: params[:portfolio_uid])
  end

  def business
    @business ||= portfolio.business || current_user.business
  end

  def event_criteria
    {
      parent_id: nil,
      trade_uid: [nil, trade.uid].uniq,
      portfolio_uid: [nil, portfolio.uid].uniq,
      business_id: business.id,
    }
  end
end
