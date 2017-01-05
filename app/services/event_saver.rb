class EventSaver
  def initialize(user)
    @user = user
  end

  def save(object, changes, parent_event)
    return if changes.empty?
    Event.create!(
      object_to_logables(object).merge(
        event_type: get_event_type(object),
        details: changes.except(*%w(id version created_at updated_at)),
        user: @user,
        object_type: object.class,
        object_id: object.id,
        parent: parent_event
      )
    )
  end

  def object_to_logables(object)
    trade = get_trade(object)
    portfolio = get_portfolio(trade, object)
    business = get_business(portfolio, object)
    {
      trade: trade,
      portfolio: portfolio,
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
end
