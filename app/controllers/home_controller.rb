class HomeController < ApplicationController
  skip_before_action :require_user

  def index
    redirect_to business_path if current_user
  end

  def about
  end
end
