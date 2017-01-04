class ConfigsController < ApplicationController
  helper_method :tab_options

  def show
    @tab = params[:tab] || tab_options.keys.first
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

  private

  def tab_options
    { 'business' => 'Business', 'user' => 'User', 'portfolios' => "Portfolio's" }
  end
end
