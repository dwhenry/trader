class PortfolioPolicy < ApplicationPolicy
  def create?
    user.role.allow?(Role::CREATE_PORTFOLIO)
  end

  def update?
    user.role.allow?(Role::EDIT_PORTFOLIO) && user.business_id == record.business_id
  end

  def event?
    record.business_id == user.business_id ||
      SharedPortfolio.exists?(portfolio_id: record.id, business_id: user.business_id)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      result = scope.where(business_id: user.business_id)
      if (shared_portfolios = SharedPortfolio.where(business_id: user.business_id).pluck(:portfolio_uid))
        result = result.or(scope.where(uid: shared_portfolios))
      end
      result
    end
  end
end
