class Role < ApplicationRecord
  SUPER_ADMIN = 'super_admin'

  # permissions
  CREATE_PORTFOLIO = 'create_portfolio'

  belongs_to :business, required: false
  has_many :permissions

  validates :name, presence: true, uniqueness: { scope: :business }
  validates :business, absence: true, if: ->(r) { r.name == SUPER_ADMIN }

  def allow?(permission_name)
    name == SUPER_ADMIN || permissions.detect { |p| p.name == permission_name }
  end
end
