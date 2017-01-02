class ConfigsController < ApplicationController
  def show
    @business = current_user.business
  end

  def update
    updater = ConfigUpdater.new(params, current_user)
    if updater.update
      flash[:info] = 'Successfully updated config'
      redirect_to config_path
    else
      flash[:danger] = 'Error updated config'
      @errors = updater.errors
      @business = current_user.business
      render :show
    end
  end
end
