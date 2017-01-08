class UsersController < ApplicationController
  def create
    user_creator = UserCreator.new(current_user, params[:emails], params[:role])
    if user_creator.save
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
end
