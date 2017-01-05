class Event < ApplicationRecord
  OLD_POS = 0
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

  def filtered_details
    filtered = details.except(*%w(trade_uid trade_version object_type config_type))

    return filtered.sort unless filtered['config']

    hash = {}
    build_config_history(filtered['config'][OLD_POS], hash, OLD_POS)
    build_config_history(filtered['config'][CURRENT_POS], hash, CURRENT_POS)
    filtered.delete('config')
    filtered.merge(hash).sort
  end

  def build_config_history(records, hash, index)
    return unless records
    records.each do |key, value|
      hash[key] ||= [nil, nil]
      hash[key][index] = value
    end
  end
end
