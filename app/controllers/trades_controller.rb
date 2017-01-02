class TradesController < ApplicationController
  def new
    @trade = Trade.new(trade_params)
  end

  def create
    @trade = Trade.new(trade_params)
    if @trade.save
      redirect_to portfolio_path(@trade.portfolio)
    else
      render :new
    end
  end

  private

  def trade_params # rubocop:disable Metrics/MethodLength
    return {} unless params[:trade]
    params[:trade][:quantity] = calc_quantity if params[:trade][:quantity].blank?
    params
      .require(:trade)
      .permit(
        :portfolio_id,
        :date,
        :quantity,
        :price,
        :currency,
        :security_id,
      )
  end

  def calc_quantity
    return nil unless params[:direction] && params[:quantity]
    (params[:direction] == 'buy' ? 1 : -1) * params[:quantity].to_i
  end
end
