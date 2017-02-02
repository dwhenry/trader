module CustomFields
  class CustomField
    include ActiveModel::Model

    class << self
      def add_field(key, field_config)
        field = CustomFields::FieldDefinition.new(field_config.merge(key: key))
        attr_accessor key
        private field.setter
        fields << field
        set_type(key, field.type) if field.type
        set_validation(key, field.validations) if field.validations
      end

      def fields
        @fields ||= []
      end

      def clean(hash)
        new(hash).as_json.reject { |_, v| v.blank? }.presence
      end

      private

      def set_type(name, type)
        case type
        when 'number'
          set_validation name, numericality: true
        end
      end

      def set_validation(name, validations)
        validates name, validations
      end
    end

    def initialize(*)
      # accessors need to be public for creation, but are made public
      # afterwards to try and enforce immutability
      accessor_methods = fields.map(&:setter)
      self.class.send :public, *accessor_methods
      super
      fields.each { |field| send(field.setter, send(field.key) || field.default) }
      self.class.send :private, *accessor_methods
    end

    def each(&block)
      self.class.fields.each(&block)
    end

    def as_json(*)
      fields.each_with_object({}) do |field, hash|
        hash[field.key] = public_send(field.key)
      end
    end

    private

    def fields
      self.class.fields
    end
  end
end
