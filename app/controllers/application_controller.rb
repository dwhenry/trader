class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :require_user
  helper_method :current_user

  include SaveWithEvents
  include BuildConfig
  include Pundit

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    flash[:alert] = 'You are not authorized to perform this action.'
    redirect_to(request.referer || root_path)
  end

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
