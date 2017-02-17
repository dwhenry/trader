class UsersController < ApplicationController
  def create
    @user_creator = UserCreator.new(user_create_params)
    if @user_creator.save
      redirect_to config_path(tab: :user)
    else
      @tab = 'user'
      render 'configs/show'
    end
  end

  def update
    @user = User.find_by!(business: current_user.business, id: params[:id])
    if @user.update(user_params)
      redirect_to config_path(tab: :user)
    else
      @tab = 'user'
      render 'configs/show'
    end
  end

  def user_params
    params
      .require(:user)
      .permit(:name)
  end

  def user_create_params
    params
      .require(:user_creator)
      .permit(:emails, :role_id)
      .merge(current_user: current_user)
  end
end
