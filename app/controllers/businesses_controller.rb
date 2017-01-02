class BusinessesController < ApplicationController
  def show
    @business = current_user.business
    @portfolios = Portfolio.where(business_id: @business.id)
  end
end
