class UsersController < ApplicationController
  def create
    emails = params[:emails].split(',').map(&:strip).uniq
    if emails.all? { |email| User.find_by(email: email).nil? && User.new(email: email).valid? }
      emails.each { |email| User.create!(business: current_user.business, email: email, role: params[:role]) }
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
