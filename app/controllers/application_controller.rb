class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :require_user
  helper_method :current_user

  include SaveWithEvents
  include BuildConfig
  include Pundit

  private

  def current_user
    @current_user ||= CurrentUser.get(self)
  end

  def require_user
    if current_user
      redirect_to new_business_path unless current_user.business
    else
      redirect_to root_path
    end
  end
end
