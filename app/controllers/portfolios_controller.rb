class PortfoliosController < ApplicationController
  def show
    @portfolio = Portfolio.find(params[:id])
  end

  def new
    @portfolio = Portfolio.new
    @configuration_options = [['Default', 0]] + Portfolio.where(business_id: current_user.business_id).pluck(:name, :id)
  end

  def create
    @portfolio = Portfolio.new(portfolio_params.merge(business: current_user.business))

    if @portfolio.save
      CustomConfig.create_for(@portfolio, Portfolio.find_by(id: params[:configuration]))
      redirect_to business_path
    else
      @configuration_options = [nil, 'Default'] + Portfolio.where(business_id: current_user.business_id).pluck(:id, :name)
      flash[:warning] = 'Error creating portfolio'
      render :new
    end
  end

  private

  def portfolio_params
    params.require(:portfolio).permit(:name)
  end
end
