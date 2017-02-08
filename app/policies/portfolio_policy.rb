class PortfolioPolicy < ApplicationPolicy
  def create?
    user.role.allow?(Role::CREATE_PORTFOLIO)
  end
end
