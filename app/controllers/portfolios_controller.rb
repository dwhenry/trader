class PortfoliosController < ApplicationController
  def show
    @portfolio = Portfolio.find(params[:id])
  end

  def create
    @portfolio = Portfolio.new(portfolio_params.merge(business: current_user.business))

    if save_with_events(@portfolio, CustomConfig.build_for(@portfolio, Portfolio.find_by(id: params[:configuration])))
      redirect_to config_path(tab: :portfolios, anchor: "portfolio-#{@portfolio.id}")
    else
      @configuration_options = [nil, 'Default'] + Portfolio.where(business_id: current_user.business_id).pluck(:id, :name)
      flash[:warning] = 'Error creating portfolio'
      render :new
    end
  end

  def update
    @portfolio = Portfolio.find(params[:id])
    @portfolio.assign_attributes(portfolio_params)

    if save_with_events(@portfolio, CustomConfig.assign_for(@portfolio, config_params(@portfolio)))
      # Event.create_portfolio(@portfolio, current_user)
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
