class TradesController < ApplicationController
  include SaveWithVersions

  def new
    @trade = Trade.new(trade_params)
  end

  def create
    @trade = Trade.new(uid: Trade.next_uid)
    if save_with_versions(@trade => trade_params)
      flash[:info] = 'Successfully created trade'
      redirect_to portfolio_path(@trade.portfolio)
    else
      flash[:warning] = 'Trade could not be created'
      render :new
    end
  end

  def edit
    @trade = Trade.current.find_by!(uid: params[:id])
    @backoffice = @trade.backoffice
  end

  def update
    @trade = Trade.find_by!(uid: params[:id])
    @backoffice = @trade.backoffice

    if save_with_versions(@trade => trade_params, @backoffice => backoffice_params)
      flash[:info] = 'Successfully updated trade'
      redirect_to edit_trade_path(@trade.uid)
    else
      flash[:warning] ||= 'Trade could not be saved'
      render :edit
    end
  end

  private

  def backoffice_params
    params
      .require(:backoffice)
      .permit(
        :state,
        :settlement_date,
      )
  end

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
        custom_instance: Trade.custom_class(params[:trade][:portfolio_id]).fields.map(&:name),
      )
  end

  def calc_quantity
    return nil unless params[:direction] && params[:quantity]
    (params[:direction] == 'buy' ? 1 : -1) * params[:quantity].to_i
  end
end
