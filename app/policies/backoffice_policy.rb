class BackofficePolicy < ApplicationPolicy
  def update?
    record.portfolio.business_id == user.business_id &&
      user.role.allow?(Role::EDIT_BACKOFFICE)
  end
end
