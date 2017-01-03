class Event < ApplicationRecord
  belongs_to :trade, required: false
  belongs_to :portfolio, required: false
  belongs_to :business
  belongs_to :user

  belongs_to :parent, class_name: 'Event', required: false
  has_many :children, foreign_key: :parent_id, class_name: 'Event'
end
