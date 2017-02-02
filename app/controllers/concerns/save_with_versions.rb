module SaveWithVersions
  def save_with_versions(objects_with_params)
    objects = objects_with_params.map do |object, changes|
      object.attributes = changes
      object
    end

    if objects.count(&:changed?) > 1
      flash[:warning] = 'Unable to update multiple objects'
      return false
    end
    return false unless objects.all?(&:valid?)

    Updater.update_all(objects, current_user)
  end

  class Updater
    def self.update_all(objects, current_user)
      ApplicationRecord.transaction do
        objects.each { |object| Updater.new(object, current_user).update }
        true
      end
    end

    def initialize(object, user)
      @object = object
      @saver = EventSaver.new(user)
    end

    def update
      return unless @object.changed?
      changes = @object.changes

      object = retire_current_object

      if object.is_a?(Trade)
        object.version += 1
        save_trade(object, changes)
      else
        object.save!
        @saver.save(object, changes, nil)
      end
    end

    def retire_current_object
      return @object if @object.new_record?

      # create the new object for later use
      new_object = @object.dup
      new_object.version += 1

      # reload the existing object and stop it being current
      @object.reload
      @object.update!(current: false)

      new_object
    end

    # object specific saving - potentially extract this to a separate class if more than one is required

    def save_trade(object, changes)
      object.version_create_callback!(@object == object ? nil : @object)
      parent_event = @saver.save(object, changes, nil)
      @saver.save(
        object.backoffice,
        backoffice_changes(@object.backoffice, object.backoffice),
        parent_event,
      )
    end

    def backoffice_changes(old_backoffice, new_backoffice)
      if new_backoffice.version == 1
        Backoffice.new(new_backoffice.attributes).changes
      else
        old_backoffice.attributes = new_backoffice.attributes
        old_backoffice.changes
      end
    end
  end
end
