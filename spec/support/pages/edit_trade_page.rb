class EditTradePage < SitePrism::Page
  set_url '/trades{/uid}/edit'

  element :direction_buy, '.t-direction-buy'
  element :direction_sell, '.t-direction-sell'
  element :date, '.t-date'
  element :quantity, '.t-quantity'
  element :price, '.t-price'
  element :currency, '.t-currency'
  element :security, '.t-security'

  element :update_trade, '.t-update-trade'

  def fill_in_trade(custom = {}) # rubocop:disable Metrics/AbcSize
    update(:date, :set, custom, :date)
    update(:quantity, :set, custom, :quantity)
    update(:price, :set, custom, :price)
    update(:currency, :set, custom, :currency)
    update(:security, :select, custom, :security)
    update("direction_#{custom[:direction]}", :select, custom, :direction)
  end

  def update(field, method, data, key)
    return unless data.key?(key)
    public_send(field).send(method, data[key])
  end

  def save
    update_trade.click
  end
end
