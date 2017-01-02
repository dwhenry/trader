class Account < ApplicationRecord
  belongs_to :business

  validates :business, presence: true
  validates :name, presence: true
end
