class NavPolicy < ApplicationPolicy
  def configure_system?
    user.role.allow?(Role::CONFIGURE_SYSTEM)
  end

  def follow_security?
    user.role.allow?(Role::FOLLOW_SECURITY)
  end
end
