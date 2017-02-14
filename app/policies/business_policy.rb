class BusinessPolicy < ApplicationPolicy
  def event?
    record.id == user.business_id
  end
end
