class Trade < ApplicationRecord
  include CustomConfigValidation

  belongs_to :security
  belongs_to :portfolio

  validates :quantity, presence: true, numericality: { other_than: 0 }
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true

  def validatables
    [self, portfolio, portfolio.business]
  end
end
