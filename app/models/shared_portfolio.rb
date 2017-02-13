class SharedPortfolio < ApplicationRecord
  belongs_to :portfolio, foreign_key: :portfolio_uid, primary_key: :uid # being shared
  belongs_to :business # shared with

  scope :for_business_id, ->(business_id) { includes(:portfolio).where(business_id: business_id) }

  validates :portfolio, presence: true
  validates :business, presence: true,
                       exclusion: { in: ->(sp) { [sp.portfolio.business] } }
  validates :access_level, inclusion: { in: %w(read) }
end
