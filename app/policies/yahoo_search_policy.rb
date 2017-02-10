class YahooSearchPolicy < ApplicationPolicy
  def show?
    user.role.allow?(Role::FOLLOW_SECURITY)
  end
end
