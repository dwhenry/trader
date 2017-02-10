class SecuritiesController < ApplicationController
  def show
    @security = policy_scope(Security).find(params[:id])
  end

  def create
    security = SecurityCreator.from_yahoo(current_user.business_id, params[:security][:ticker])
    authorize security
    security.save!
    redirect_to security
  end
end
