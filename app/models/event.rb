class Event < ApplicationRecord
  CURRENT_POS = 1

  belongs_to :trade, required: false, foreign_key: :trade_uid, primary_key: :uid
  belongs_to :portfolio, required: false
  belongs_to :business
  belongs_to :user

  belongs_to :parent, class_name: 'Event', required: false
  has_many :children, foreign_key: :parent_id, class_name: 'Event'

  def current(field)
    details[field.to_s][CURRENT_POS]
  end

  def lookup(field)
    field = field.to_s
    field.classify.constantize.find(current("#{field}_id"))
  end

  def edited?(*fields)
    (details.keys & fields.map(&:to_s)).any?
  end
end
