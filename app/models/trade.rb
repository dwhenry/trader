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

  CHARS = [*'A'..'Z', *'a'..'z', *'0'..'9'].freeze
  def self.next_uid
    uid = (0..7).map { CHARS.sample }.join
    Trade.find_by(uid: uid) ? next_uid : uid
  end
end
