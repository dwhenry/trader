class BusinessesController < ApplicationController
  before_action :one_business_only, only: %i(new create)
  skip_before_action :require_user, only: %i(new create)

  def show
    @business = current_user.business
    @portfolios = Portfolio.where(business_id: @business.id)
  end

  def new
    @business = Business.new
    @portfolio = Portfolio.new
  end

  def create
    @business = Business.new(business_params)
    @portfolio = @business.portfolios.new(portfolio_params)

    if @business.save
      CustomConfig.create_for(@business)
      CustomConfig.create_for(@portfolio)
      current_user.update(business: @business)
      redirect_to business_path
    else
      flash[:warning] = 'Error creating business'
      render :new
    end
  end

  def update
    @business = current_user.business
    if @business.update(business_params) && CustomConfig.find_for(@business).update(config: config_params)
      redirect_to config_path(tab: :business)
    else
      @tab = 'business'
      render 'configs/show'
    end
  end

  private

  def business_params
    params.require(:business).permit(:name)
  end

  def portfolio_params
    params.require(:portfolio).permit(:name)
  end

  def config_params
    params.require(:config).permit(CustomConfig.defaults(current_user.business).keys)
  end

  def one_business_only
    if current_user
      if current_user.business
        redirect_to business_path
      end
    else
      redirect_to root_path
    end
  end
end
