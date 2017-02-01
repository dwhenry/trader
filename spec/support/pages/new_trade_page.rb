class NewTradePage < SitePrism::Page
  set_url '/trades/new'

  element :direction_buy, '.t-direction-buy'
  element :direction_sell, '.t-direction-sell'
  element :date, '.t-date'
  element :quantity, '.t-quantity'
  element :price, '.t-price'
  element :currency, '.t-currency'
  element :security, '.t-security'

  element :create_trade, '.t-create-trade'

  elements :custom_fields, '.t-custom-field'

  def fill_in_trade(custom = {}) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    date.set Time.zone.today
    quantity.set 100
    price.set 12.34
    currency.set 'AUD'
    security.select Security.first.name
    public_send("direction_#{custom.fetch(:direction, 'buy')}").set true

    custom.each do |field_name, value|
      field = find_custom(field_name)
      next unless field
      set_custom(field, value)
    end
  end

  def save
    create_trade.click
  end

  private

  def find_custom(field_name)
    custom_fields.detect { |elem| elem['name'] =~ /\[#{field_name}\]$/ }
  end

  def set_custom(field, value)
    field.set value
  end
end
