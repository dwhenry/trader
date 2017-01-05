class EventsController < ApplicationController
  def index
    criteria = {
      parent_id: nil,
      trade_uid: [nil, params[:trade_uid]].uniq,
      portfolio_id: [nil, params[:portfolio_id]].uniq,
      business_id: current_user.business_id
    }

    @events = Event.where(criteria).includes(:children).order(created_at: :desc).limit(10)

    if request.xhr?
      render 'index', layout: false
    end
  end
end
