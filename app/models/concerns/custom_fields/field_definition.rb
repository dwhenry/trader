module CustomFields
  class FieldDefinition
    attr_reader :default, :key, :type, :validations

    def initialize(options={})
      options = options.with_indifferent_access
      @default = options[:default]
      @key = options.fetch(:key)
      @type = options.fetch(:type, 'string')
      @validations = options[:validations]
    end

    def setter
      "#{key}="
    end
  end
end
