class CustomConfig < ApplicationRecord
  DEFAULT_CONFIG = {
    'PORTFOLIO' => { allow_negative_position: false },
  }.freeze

  class << self
    def create_for(object, clone=nil)
      create(
        object_type: object.class.to_s,
        object_id: object.id,
        config: find_for(clone)&.config || DEFAULT_CONFIG[object.class.to_s]
      )
    end

    def find_for(object)
      return nil unless object
      find_by(object_type: object.class.to_s, object_id: object.id)
    end
  end
end
