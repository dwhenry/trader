module SaveWithVersions
  def save_with_versions(objects_with_params)
    ApplicationRecord.transaction do
      objects = objects_with_params.map do |object, changes|
        object.attributes = changes
        object
      end

      if objects.count(&:changed?) > 1
        flash[:warning] = 'Unable to update multiple objects'
        return false
      end
      return false unless objects.all?(&:valid?)

      objects.each { |object| Updater.new(object, current_user).update }
      true
    end
  end

  class Updater
    def initialize(object, user)
      @object = object
      @saver = EventSaver.new(user)
    end

    def update
      return unless @object.changed?
      changes = @object.changes

      object = retire_current_object

      case object
      when Trade
        save_trade(object, changes)
      else
        object.save!
        @saver.save(object, changes, nil)
      end
    end

    def save_trade(object, changes)
      object.version_create_callback!(@object == object ? nil : @object)
      parent_event = @saver.save(object, changes, nil)
      backoffice = @object.backoffice
      backoffice_changes = if object.backoffice.version == 1
                             Backoffice.new(backoffice.attributes).changes
                           else
                             backoffice = @object.backoffice
                             backoffice.attributes = object.backoffice.attributes
                             backoffice.changes
                           end
      @saver.save(object.backoffice, backoffice_changes, parent_event)
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
  end
end
