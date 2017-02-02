module CustomFields
  extend ActiveSupport::Concern

  included do
    validates_with ActiveRecord::Validations::AssociatedValidator, attributes: [:custom_instance]
  end

  def custom_class
    @custom_class ||= self.class.custom_class(public_send(self.class.custom_field_key))
  end

  def custom_instance
    custom_class.new(custom)
  end

  def custom_instance=(hash)
    self.custom = custom_class.clean(hash)
  end

  module ClassMethods
    def setup_custom_field(custom_field_key, klass = nil)
      @_custom_field_key = custom_field_key
      @_custom_field_class = klass || custom_field_key.to_s.gsub(/_id$/, '').classify
    end

    def custom_field_key
      @_custom_field_key
    end

    def custom_class(key_id)
      name = "Custom#{key_id}"
      return const_get(name) if const_defined?(name)

      config = CustomConfig.find_by(object_id: key_id, object_type: @_custom_field_class.to_s, config_type: 'fields')
      return CustomField if config.nil?
      const_set(name, build_class(config))
    end

    private

    def build_class(config)
      Class.new(CustomField) do
        config.config.each do |key, field_config|
          add_field(key, field_config)
        end
      end
    end
  end

  class CustomField
    include ActiveModel::Model

    class << self
      def add_field(key, field_config)
        attr_accessor key
        private "#{key}="
        fields << OpenStruct.new(field_config.merge(key: key))
        set_type(key, field_config['type']) if field_config['type']
        set_validation(key, field_config['validations']) if field_config['validations']
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
      accessor_methods = fields.map { |f| "#{f.key}=" }
      self.class.send :public, *accessor_methods
      super
      fields.each { |field| send("#{field.key}=", send(field.key) || field.default) }
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
