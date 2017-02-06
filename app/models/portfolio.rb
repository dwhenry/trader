class Portfolio < ApplicationRecord
  belongs_to :business
  has_many :trades
  default_scope { where(current: true) }

  validates :name, presence: true
  validates :name, uniqueness: { scope: [:business, :current] }, if: :current?
end
