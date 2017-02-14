class TradePolicy < ApplicationPolicy
  def new?
    record.portfolio&.business_id == user.business_id &&
      user.role.allow?(Role::CREATE_TRADE)
  end
  alias create? new?

  def can_edit?
    record.portfolio.business_id == user.business_id &&
      (user.role.allow?(Role::EDIT_TRADE) || user.role.allow?(Role::EDIT_BACKOFFICE))
  end

  def update?
    record.portfolio.business_id == user.business_id &&
      user.role.allow?(Role::EDIT_TRADE)
  end

  def event?
    record.portfolio.business_id == user.business_id ||
      SharedPortfolio.exists?(portfolio_uid: record.portfolio.uid, business_id: user.business_id)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      extended_scope = scope.includes(:portfolio)

      result = extended_scope.where(portfolios: { business_id: user.business_id })
      if (shared_portfolios = SharedPortfolio.where(business_id: user.business_id).pluck(:portfolio_uid))
        result = result.or(extended_scope.where(portfolios: { uid: shared_portfolios }))
      end
      result
    end
  end
end
