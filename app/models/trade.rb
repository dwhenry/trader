class Trade < ApplicationRecord
  include CustomConfigValidation

  belongs_to :security
  belongs_to :portfolio

  validates :currency, presence: true
  validates :current, uniqueness: { scope: :uid, if: ->(t) { t.current } }
  validates :date, presence: true
  validates :portfolio, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :quantity, presence: true, numericality: { other_than: 0 }
  validates :security_id, presence: true
  validates :uid, presence: true, length: { is: 8 }

  scope :current, -> { where(current: true) }

  def validatables
    [self, portfolio, portfolio.business]
  end

  def ==(other)
    uid == other.uid &&
      date == other.date &&
      quantity == other.quantity &&
      price == other.price &&
      currency == other.currency &&
      portfolio_id == other.portfolio_id &&
      security_id == other.security_id
  end

  def save_new_version
    self.class.transaction do
      begin
        current_trade = self.class.current.find_by!(uid: uid)
        current_trade.update!(current: false)
        self.version = current_trade.version + 2
        if quantity.positive?
          save!
          current_trade.make_offset!
        else
          current_trade.make_offset!
          save!
        end
        return true
      rescue
        raise ActiveRecord::Rollback
      end
    end
    self.current = false
    valid?
    false
  end

  def make_offset!
    Trade.create!(
      uid: uid,
      date: date,
      quantity: -quantity,
      price: price,
      currency: currency,
      portfolio_id: portfolio_id,
      security_id: security_id,
      offset_trade: true,
      current: false,
      version: version + 1,
    )
  end

  CHARS = [*'A'..'Z', *'a'..'z', *'0'..'9'].freeze
  def self.next_uid
    uid = (0..7).map { CHARS.sample }.join
    Trade.find_by(uid: uid) ? next_uid : uid
  end
end
