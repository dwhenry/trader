class SecuritiesController < ApplicationController
  def show
    @security = Security.find(params[:id])
  end

  def create
    security = SecurityCreator.from_yahoo(current_user.business_id, params[:security][:ticker])
    security.save!
    redirect_to security
  end
end
