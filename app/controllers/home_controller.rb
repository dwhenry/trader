class HomeController < ApplicationController
  skip_before_action :require_user

  def index
  end

  def about
  end
end
