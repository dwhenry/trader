class EventSaver
  def initialize(user)
    @user = user
  end

  def save(object, changes, parent_event) # rubocop:disable Metrics/MethodLength
    return if changes.empty?
    Event.create!(
      object_to_logables(object).merge(
        event_type: get_event_type(object),
        details: clean(changes),
        user: @user,
        object_type: object.class,
        object_id: object.id,
        parent: parent_event,
      ),
    )
  end

  def object_to_logables(object)
    trade = get_trade(object)
    portfolio = get_portfolio(trade, object)
    business = get_business(portfolio, object)
    {
      trade: trade,
      portfolio_uid: portfolio&.uid,
      business: business,
    }
  end

  def get_event_type(object)
    return 'edit' if object.respond_to?(:version) && object.version > 1
    object.created_at == object.updated_at ? 'create' : 'edit'
  end

  def get_trade(object)
    return object if object.is_a?(Trade)
    return object.trade if object.respond_to?(:trade)
    nil
  end

  def get_portfolio(trade, object)
    return trade.portfolio if trade
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

  def clean(changes)
    changes = changes.except('uid', 'id', 'version', 'created_at', 'updated_at')

    %w(config custom).each do |key|
      next unless changes.key?(key)
      changes = changes.except('object_id', 'object_type', 'config_type')
      changes.merge!(transform_field(*changes.delete(key)))
    end
    changes
  end

  def transform_field(from, to)
    from ||= {}
    to ||= {}
    fields = from.keys | to.keys
    fields.each_with_object({}) do |field, hash|
      hash[field] = [from[field], to[field]]
    end
  end
end
