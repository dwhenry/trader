class Trade < ApplicationRecord
  include CustomConfigValidation
  include CustomFields
  setup_custom_field :portfolio_id, config_type: CustomConfig::TRADE_FIELDS

  belongs_to :security
  belongs_to :portfolio
  has_one :scoped_backoffice,
          -> { where('backoffices.trade_version = trades.version').current },
          foreign_key: :trade_uid,
          primary_key: :uid,
          class_name: 'Backoffice'
  has_one :backoffice,
          ->(trade) { where(trade_version: trade.version).current },
          foreign_key: :trade_uid,
          primary_key: :uid

  validates :currency, presence: true
  validates :current, uniqueness: { scope: :uid, if: ->(t) { t.current } }
  validates :date, presence: true
  validates :portfolio, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :quantity, presence: true, numericality: { other_than: 0 }
  validates :security_id, presence: true
  validates :uid, presence: true, length: { is: 8 }
  validate do |t|
    errors.add(:security_id, 'does not belong to business') unless t.security&.business_id == t.portfolio&.business_id
  end

  scope :current, -> { where(current: true) }
  scope :unsettled, -> { includes(:scoped_backoffice).where.not(backoffices: { state: 'settled' }) }

  def validatables
    [self, portfolio, portfolio.business]
  end

  def version_create_callback!(previous)
    if quantity.positive?
      save!
      Trade.make_offset!(previous)
    else
      Trade.make_offset!(previous)
      save!
    end
    Backoffice.create_from!(self)
  end

  CHARS = [*'A'..'Z', *'a'..'z', *'0'..'9'].freeze
  def self.next_uid
    uid = (0..7).map { CHARS.sample }.join
    Trade.find_by(uid: uid) ? next_uid : uid
  end

  def self.make_offset!(trade)
    return unless trade
    offset = trade.dup
    offset.update(
      quantity: -trade.quantity,
      version: trade.version + 1,
      offset_trade: true,
    )
  end
end
