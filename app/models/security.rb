class Security < ApplicationRecord
  validates :name, presence: true
  validates :ticker, presence: true
end
