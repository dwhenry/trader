class UserSetupsController < ApplicationController
  def new
    @user_setup = UserSetup.new(user_setup_params)
    render params.fetch(:step, 'naming')
  end

  def create
    @user_setup = UserSetup.new(user_setup_params, params[:step])
    if @user_setup.complete? && @user_setup.save(current_user)
      redirect_to business_path
    else
      redirect_to new_user_setup_path(@user_setup.serialize)
    end
  end

  private

  def user_setup_params
    return {} unless params[:user_setup]
    params.require(:user_setup).permit!
  end

  def require_user
    redirect_to root_path unless current_user
  end
end
