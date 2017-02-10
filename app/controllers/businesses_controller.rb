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

  def create # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    @business = Business.new(business_params)
    @portfolio = Portfolio.new(portfolio_params.merge(business: @business, uid: SecureRandom.uuid))
    current_user.assign_attributes(business: @business)

    roles = Role.default_roles(@business)
    current_user.role = roles.first
    if save_with_events(
      [@business, config_for(@business), *roles],
      [@portfolio, config_for(@portfolio)],
      [@portfolio, config_for(@portfolio)],
      [current_user],
    )
      redirect_to business_path
    else
      flash[:warning] = 'Error creating business'
      render :new
    end
  end

  def update
    @business = current_user.business
    @business.assign_attributes(business_params)
    if save_with_events(@business, config_for(@business, params: config_params))
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
      redirect_to business_path if current_user.business
    else
      redirect_to root_path
    end
  end
end
