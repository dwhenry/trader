module CustomFields
  extend ActiveSupport::Concern

  included do
    validates_with ActiveRecord::Validations::AssociatedValidator, attributes: [:custom_instance]
  end

  def custom_class
    @custom_class ||= self.class.custom_class(public_send(self.class.custom_field_key))
  end

  def custom_instance
    @custom_instance ||= custom_class.new(custom)
  end

  def custom_instance=(hash)
    @custom_instance = nil
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
end
