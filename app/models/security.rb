class Security < ApplicationRecord
  belongs_to :business

  validates :currency, presence: true
  validates :name, presence: true, exclusion: { in: ['N/A'] }
  validates :ticker, presence: true, uniqueness: { scope: :business_id }
end
