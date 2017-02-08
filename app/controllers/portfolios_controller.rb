class PortfoliosController < ApplicationController
  def show
    @portfolio = Portfolio.find(params[:id])
  end

  def create
    authorize Portfolio
    @new_portfolio = Portfolio.new(portfolio_params.merge(business: current_user.business, uid: SecureRandom.uuid))

    if save_with_events(@new_portfolio, config_for(@new_portfolio, clone_id: params[:configuration]))
      redirect_to config_path(tab: :portfolios, anchor: "portfolio-#{@new_portfolio.id}")
    else
      @tab = 'portfolios'
      render 'configs/show'
    end
  end

  def update
    @portfolio = Portfolio.find(params[:id])
    @portfolio.assign_attributes(portfolio_params)

    if save_with_events(@portfolio, config_for(@portfolio, params: config_params(@portfolio)))
      redirect_to config_path(tab: :portfolios, anchor: "portfolio-#{@portfolio.id}")
    else
      @tab = 'portfolios'
      render 'configs/show'
    end
  end

  private

  def portfolio_params
    params.require(:portfolio).permit(:name)
  end

  def config_params(portfolio)
    params.require(:config).permit(CustomConfig.defaults(portfolio).keys)
  end
end
