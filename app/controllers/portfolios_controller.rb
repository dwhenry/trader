class PortfoliosController < ApplicationController
  def show
    @portfolio = Portfolio.find(params[:id])
  end

  def new
    @user_setup = UserSetup.new(user_setup_params)
  end

  def create
    @user_setup = UserSetup.new(user_setup_params.merge(business: current_user.business))

    if @user_setup.save(current_user)
      flash[:info] = 'Successfully created portfolio'
      redirect_to business_path
    else
      flash[:warning] = 'Error creating portfolio'
      render :new
    end
  end

  private

  def user_setup_params
    return {} unless params[:user_setup]
    params.require(:user_setup).permit!
  end
end
