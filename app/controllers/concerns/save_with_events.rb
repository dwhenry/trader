module SaveWithEvents
  extend ActiveSupport::Concern
  class MissingUser < StandardError; end

  private

  def _event_logger
    @event_logger ||= begin
      raise MissingUser unless current_user
      Logger.new(current_user)
    end
  end

  def save_with_events(*objects)
    _event_logger.save(*objects)
  end

  class Logger
    def initialize(user)
      @saver = EventSaver.new(user)
    end

    def save(*objects)
      return false unless objects.flatten.all?(&:valid?)

      ApplicationRecord.transaction do
        # this allow different events to be grouped even when they are all saved together
        if objects.first.is_a?(Array)
          objects.each { |grouped_objects| save_objects(grouped_objects)}
        else
          save_objects(objects)
        end
      end
    end

    def save_objects(objects)
      changes = objects.map { |object| [object, object.changes] }
      objects.map(&:save!)
      parent_event = nil
      changes.each do |object, object_changes|
        event = @saver.save(object, object_changes, parent_event)
        parent_event ||= event
      end
    end
  end
end
