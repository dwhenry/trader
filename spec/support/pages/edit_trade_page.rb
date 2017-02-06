class EditTradePage < SitePrism::Page
  set_url '/trades{/uid}/edit'

  element :direction_buy, '.t-direction-buy'
  element :direction_sell, '.t-direction-sell'
  element :date, '.t-date'
  element :quantity, '.t-quantity'
  element :price, '.t-price'
  element :currency, '.t-currency'
  element :security, '.t-security'

  # custom fields
  elements :custom_fields, '.t-custom-field'

  # backoffice
  element :state, '.t-state'

  element :update_trade, '.t-update-trade'

  def fill_in_trade(custom = {}) # rubocop:disable Metrics/MethodLength
    update(:date, :set, custom, :date)
    update(:quantity, :set, custom, :quantity)
    update(:price, :set, custom, :price)
    update(:currency, :set, custom, :currency)
    update(:security, :select, custom, :security)
    update("direction_#{custom[:direction]}", :select, custom, :direction)
    update(:state, :set, custom, :state)

    custom.each do |field_name, value|
      field = find_custom(field_name)
      next unless field
      set_custom(field, value)
    end
  end

  def save
    update_trade.click
  end

  private

  def find_custom(field_name)
    custom_fields.detect { |elem| elem['name'] =~ /\[#{field_name}\]$/ }
  end

  def set_custom(field, value)
    field.set value
  end

  def update(field, method, data, key)
    return unless data.key?(key)
    public_send(field).send(method, data[key])
  end
end
