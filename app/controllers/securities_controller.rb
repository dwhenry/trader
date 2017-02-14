class SecuritiesController < ApplicationController
  def show
    security = Security.find(params[:id])
    @security = policy_scope(Security).find_by!(ticker: security.ticker)
  end

  def create
    security = SecurityCreator.from_yahoo(current_user.business_id, params[:security][:ticker])
    authorize security
    security.save!
    redirect_to security
  end
end
