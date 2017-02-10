# frozen_string_literal: true
class Role < ApplicationRecord
  SUPER_ADMIN = 'super_admin'

  # permissions
  CREATE_PORTFOLIO = 'create_portfolio'
  EDIT_PORTFOLIO = 'edit_portfolio'
  CONFIGURE_SYSTEM = 'configure_system'
  FOLLOW_SECURITY = 'follow_security'

  DEFAULT_ADMIN = [
    CREATE_PORTFOLIO,
    EDIT_PORTFOLIO,
    CONFIGURE_SYSTEM,
    FOLLOW_SECURITY,
  ].freeze
  DEFAULT_TRADER = [
    FOLLOW_SECURITY,
  ].freeze

  DEFAULT_BACKOFFICE = [

  ].freeze

  belongs_to :business, required: false

  has_many :permissions

  scope :for_business, ->(business) { where(business_id: [nil, business.id]) }
  validates :name, presence: true, uniqueness: { scope: :business }
  validates :business, absence: true, if: ->(r) { r.name == SUPER_ADMIN }

  def self.default_roles(business)
    {
      admin: Role::DEFAULT_ADMIN,
      trader: Role::DEFAULT_TRADER,
      backoffice: Role::DEFAULT_BACKOFFICE,
    }.map do |name, permissions|
      role = Role.new(name: name, business: business)
      permissions.map { |permission_name| role.permissions.build(name: permission_name) }
      role
    end
  end

  def pretty_name
    name.titlecase
  end

  def allow?(permission_name)
    name == SUPER_ADMIN || permissions.detect { |p| p.name == permission_name }
  end
end
