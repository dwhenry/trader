class PortfolioPolicy < ApplicationPolicy
  def create?
    user.role.allow?(Role::CREATE_PORTFOLIO)
  end

  def update?
    user.role.allow?(Role::EDIT_PORTFOLIO) && user.business_id == record.business_id
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(business_id: user.business_id)
    end
  end
end
