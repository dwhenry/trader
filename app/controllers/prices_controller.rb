class PricesController < ApplicationController
  def index # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    prices = policy_scope(Security).find(params[:security_id]).prices.order(:date).map do |price|
      {
        date: price.date,
        open: price.open.to_f,
        close: price.close.to_f,
        high: price.high.to_f,
        low: price.low.to_f,
        volume: price.volume,
      }
    end
    render json: prices
  end
end
