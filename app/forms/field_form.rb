class FieldForm
  include ActiveModel::Model

  attr_accessor :object_id, :object_type, :config_type, :name, :type, :default
  attr_accessor :validates_presence

  validates :object_id, :object_type, presence: true
  validates :name, presence: true
  validates :type, presence: true

  def as_json
    hash = {
      name: name,
      type: type,
    }
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
