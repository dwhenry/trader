class Backoffice < ApplicationRecord
  include CustomFields
  setup_custom_field :portfolio_id, config_type: CustomConfig::BACKOFFICE_FIELDS

  belongs_to :trade, foreign_key: :trade_uid, primary_key: :uid

  delegate :portfolio_id, to: :trade

  validates :state, presence: true
  validates :version, presence: true
  validates :current, uniqueness: { scope: [:trade_uid, :trade_version] }

  scope :current, -> { where(current: true) }

  def self.create_from!(trade)
    create!(
      trade_uid: trade.uid,
      trade_version: trade.version,
      state: 'Pending',
      version: (where(trade_uid: trade.uid).maximum(:version) || 0) + 1,
      current: true,
    )
  end
end
