class Trade < ApplicationRecord
  include CustomConfigValidation

  belongs_to :security
  belongs_to :portfolio
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

  scope :current, -> { where(current: true) }

  class CustomField
    include ActiveModel::Model

    attr_accessor :description

    def each(&block)
      [OpenStruct.new(name: 'description')].each(&block)
    end
  end

  def custom_class
    CustomField
  end

  def custom_instance
    custom_class.new(custom)
  end

  def custom_instance=(hash)
    self.custom = CustomField.new(hash).as_json.reject { |_, b| b.blank? }.presence
  end

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
