class TradesController < ApplicationController
  def new
    @trade = Trade.new(trade_params)
  end

  def create
    @trade = Trade.new(trade_params.merge(uid: Trade.next_uid))
    if @trade.save
      flash[:info] = 'Successfully saved trade'
      redirect_to portfolio_path(@trade.portfolio)
    else
      flash[:warning] = 'Trade could not be created'
      render :new
    end
  end

  def edit
    @trade = Trade.current.find_by!(uid: params[:id])
  end

  def update
    trade = Trade.current.find_by!(uid: params[:id])
    @trade = Trade.new(trade_params)
    if @trade == trade
      flash[:info] = 'Trade has not been modified'
      redirect_to edit_trade_path(@trade.uid)
    elsif @trade.save_new_version
      flash[:info] = 'Successfully updated trade'
      redirect_to portfolio_path(@trade.portfolio)
    else
      flash[:warning] = 'Trade could not be saved'
      render :edit
    end
  end

  private

  def trade_params # rubocop:disable Metrics/MethodLength
    return {} unless params[:trade]
    params[:trade][:quantity] = calc_quantity
    params
      .require(:trade)
      .permit(
        :uid,
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
