class FieldForm
  TYPES = %w(string number list).freeze
  include ActiveModel::Model

  attr_accessor :owner_id, :owner_type, :config_type
  attr_accessor :name, :type, :default, :values
  attr_accessor :validates_presence, :validates_inclusion

  validates :owner_id, :owner_type, presence: true
  validates :name, presence: true
  validates :type, presence: true, inclusion: TYPES
  validates :values, presence: true, if: ->(f) { f.type == 'list' }

  def as_json
    {
      key => JsonFactory.for(self).as_json,
    }
  end

  def key
    name.downcase.gsub(/[^a-z0-9]+/, '_')
  end

  def values_array
    values.split(',')
  end

  def validations=(hash) # ideally this would be a private method as it is only used for de/serialization
    return unless hash.is_a?(Hash)
    self.validates_presence = true if hash['presence']
    self.validates_inclusion = true if hash['inclusion']
  end

  def values=(values)
    @values = if values.is_a?(Array)
                values.join(',')
              else
                values
              end
  end

  class JsonFactory < SimpleDelegator
    def self.for(object)
      case object.type
      when 'list'
        JsonListFactory.new(object)
      else
        new(object)
      end
    end

    def as_json
      hash = {
        name: name,
        type: type,
      }
      hash[:default] = default if default.present?
      if validates_presence
        hash[:validations] ||= {}
        hash[:validations][:presence] = true
      end
      hash
    end
  end

  class JsonListFactory < JsonFactory
    def as_json
      hash = super
      hash[:values] = values_array if type == 'list'
      if validates_inclusion && type == 'list'
        hash[:validations] ||= {}
        hash[:validations][:inclusion] = values_array
      end
      hash
    end
  end
end
