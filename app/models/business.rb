class Business < ApplicationRecord
  has_many :portfolios
  validates :name, presence: true, uniqueness: true
end
