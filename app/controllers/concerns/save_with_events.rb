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
      @user = user
    end

    def save(*objects)
      return false unless objects.all?(&:valid?)

      ApplicationRecord.transaction do
        changes = objects.map { |object| [object, object.changes] }
        objects.map(&:save!)
        parent_event = nil
        changes.each do |object, object_changes|
          event = save_events(object, object_changes, parent_event)
          parent_event ||= event
        end
      end
    end

    private

    def save_events(object, changes, parent_event)
      return if changes.empty?
      Event.create!(
        object_to_logables(object).merge(
          event_type: object.created_at == object.updated_at ? 'create' : 'edit',
          details: changes,
          user: @user,
          object_type: object.class,
          parent: parent_event
        )
      )
    end

    def object_to_logables(object)
      trade = object if object.is_a?(Trade)
      portfolio = get_portfolio(object)
      business = get_business(portfolio, object)
      {
        trade: trade,
        portfolio: portfolio,
        business: business,
      }
    end

    def get_portfolio(object)
      return object if object.is_a?(Portfolio)
      return object.portfolio if object.respond_to?(:portfolio)
      return object.object if object.is_a?(CustomConfig) && object.object.is_a?(Portfolio)
      nil
    end

    def get_business(portfolio, object)
      return portfolio.business if portfolio
      return object if object.is_a?(Business)
      return object.object if object.is_a?(CustomConfig) && object.object.is_a?(Business)
      nil
    end
  end
end
