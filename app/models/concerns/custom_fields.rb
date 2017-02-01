module CustomFields
  extend ActiveSupport::Concern

  def custom_class
    @custom_class ||= self.class.custom_class(public_send(self.class.custom_field_key))
  end

  def custom_instance
    custom_class.new(custom)
  end

  def custom_instance=(hash)
    self.custom = custom_class.new(hash).as_json.reject { |_, b| b.blank? }.presence
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
      name = "CustomTrade#{key_id}"
      return self.class.const_get(name) if self.class.const_defined?(name)

      config = CustomConfig.find_by(object_id: key_id, object_type: @_custom_field_class.to_s, config_type: 'fields')
      return CustomField if config.nil?
      self.class.const_set(name, build_class(config))
    end

    private

    def build_class(config)
      Class.new(CustomField) do
        config.config.each do |field, field_config|
          add_field(field, field_config)
        end
      end
    end
  end

  class CustomField
    include ActiveModel::Model

    class << self
      def add_field(name, field_config)
        attr_accessor name
        fields << OpenStruct.new(name: name)
        set_default(name, field_config['default']) if field_config['default']
      end

      def fields
        @fields ||= []
      end

      def set_default(name, default)
        define_method :initialize do |*args|
          super(*args)
          instance_variable_set("@#{name}", instance_variable_get("@#{name}") || default)
        end
      end
    end

    def each(&block)
      self.class.fields.each(&block)
    end
  end
end
