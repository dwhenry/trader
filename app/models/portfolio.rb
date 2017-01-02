class Portfolio < ApplicationRecord
  belongs_to :business
  has_many :trades

  validates :name, presence: true, uniqueness: { scope: :business }
end
