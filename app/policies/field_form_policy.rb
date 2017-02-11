class FieldFormPolicy < ApplicationPolicy
  def new?
    case record.owner_type
    when 'Portfolio'
      Portfolio.exists?(id: record.owner_id, business_id: user.business_id)
    else
      false
    end
    user.role.allow?(Role::FOLLOW_SECURITY)
  end
  alias create? new?
  alias destroy? new?
end
