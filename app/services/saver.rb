class Saver
  attr_reader :objects

  def initialize(objects_with_params)
    @objects_with_params = objects_with_params
  end

  def save
    ApplicationRecord.transaction do
      @objects = @objects_with_params.map do |object, changes|
        object.attributes = changes
        object
      end

      return unless @objects.all?(&:valid?)

      @objects.map! { |object| object.changed? ? update(object) : object }
      true
    end
  end

  private

  def update(object)
    new_object = retire_current_object(object)

    # check for post create callback so they can be run here if exists
    if new_object.respond_to?(:version_create_callback!)
      new_object.version_create_callback!(object == new_object ? nil : object)
    else
      new_object.save!
    end
    new_object
  end

  def retire_current_object(object)
    return object if object.new_record?

    # create the new object for later use
    new_object = object.dup
    new_object.version += 1

    # reload the existing object and stop it being current
    object.reload
    object.update!(current: false)

    new_object
  end
end
