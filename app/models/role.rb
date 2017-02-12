# frozen_string_literal: true
class Role < ApplicationRecord
  SUPER_ADMIN = 'super_admin'

  # permissions
  CREATE_PORTFOLIO = 'create_portfolio'
  EDIT_PORTFOLIO = 'edit_portfolio'
  CONFIGURE_SYSTEM = 'configure_system'
  FOLLOW_SECURITY = 'follow_security'
  CREATE_TRADE = 'create_trade'
  EDIT_TRADE = 'edit_trade'
  EDIT_BACKOFFICE = 'edit_backoffice'

  DEFAULT_ADMIN = [
    CREATE_PORTFOLIO,
    EDIT_PORTFOLIO,
    CONFIGURE_SYSTEM,
    FOLLOW_SECURITY,
    CREATE_TRADE,
    EDIT_TRADE,
  ].freeze

  DEFAULT_TRADER = [
    FOLLOW_SECURITY,
    CREATE_TRADE,
    EDIT_TRADE,
  ].freeze

  DEFAULT_BACKOFFICE = [
    EDIT_BACKOFFICE,
  ].freeze

  belongs_to :business, required: false

  scope :for_business, ->(business) { where(business_id: [nil, business.id]) }
  scope :settable_for_user, ->(user) { for_business(user.business).where(level: 0..user.role.level) }
  validates :name, presence: true, uniqueness: { scope: :business }
  validates :business, absence: true, if: ->(r) { r.name == SUPER_ADMIN }

  def self.default_roles(business)
    {
      admin: Role::DEFAULT_ADMIN,
      trader: Role::DEFAULT_TRADER,
      backoffice: Role::DEFAULT_BACKOFFICE,
    }.map do |name, permissions|
      Role.new(name: name, business: business, permissions: permissions)
    end
  end

  def pretty_name
    name.titlecase
  end

  def allow?(permission_name)
    name == SUPER_ADMIN || permissions.include?(permission_name)
  end
end
