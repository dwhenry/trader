class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :require_user
  helper_method :current_user

  def current_user
    @current_user ||= CurrentUser.get(self)
  end

  def require_user
    current_user || redirect_to(root_path)
  end
end
