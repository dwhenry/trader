class FieldForm
  TYPES = %w(string number list).freeze
  include ActiveModel::Model

  attr_accessor :owner_id, :owner_type, :config_type
  attr_accessor :name, :type, :default, :values
  attr_accessor :validates_presence

  validates :owner_id, :owner_type, presence: true
  validates :name, presence: true
  validates :type, presence: true, inclusion: TYPES
  validates :values, presence: true, if: ->(f) { f.type == 'list' }

  def as_json
    hash = {
      name: name,
      type: type,
    }
    hash[:values] = values if type == 'list'
    hash[:default] = default if default.present?
    hash[:validations] = { presence: true } if validates_presence

    { key => hash }
  end

  def key
    name.downcase.gsub(/[^a-z0-9]+/, '_')
  end

  def validations=(hash) # ideally this would be a private method as it is only used for de/serialization
    return unless hash.is_a?(Hash)
    self.validates_presence = true if hash['presence']
  end
end
