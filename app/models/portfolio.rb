class Portfolio < ApplicationRecord
  belongs_to :business

  validates :name, presence: true, uniqueness: { scope: :business }
end
