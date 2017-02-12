class Security < ApplicationRecord
  belongs_to :business
  has_many :prices, foreign_key: :ticker, primary_key: :ticker
  has_one :today_price,
          -> { where(date: Price.where('date <= ?', Time.zone.today).maximum(:date)) },
          class_name: 'Price',
          foreign_key: :ticker,
          primary_key: :ticker
  validates :currency, presence: true
  validates :name, presence: true, exclusion: { in: ['N/A'] }
  validates :ticker, presence: true, uniqueness: { scope: :business_id }
end
