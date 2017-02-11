class SecurityPolicy < ApplicationPolicy
  def create?
    user.role.allow?(Role::FOLLOW_SECURITY)
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.where(business_id: user.business_id)
    end
  end
end
