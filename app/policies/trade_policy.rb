class TradePolicy < ApplicationPolicy
  def new?
    record.portfolio&.business_id == user.business_id &&
      user.role.allow?(Role::CREATE_TRADE)
  end
  alias create? new?

  def edit?
    record.portfolio.business_id == user.business_id &&
      (user.role.allow?(Role::EDIT_TRADE) || user.role.allow?(Role::EDIT_BACKOFFICE))
  end

  def update?
    record.portfolio.business_id == user.business_id &&
      user.role.allow?(Role::EDIT_TRADE)
  end
end
