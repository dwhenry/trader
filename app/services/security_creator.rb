class SecurityCreator
  def self.from_yahoo(business_id, ticker) # rubocop:disable Metrics/MethodLength
    results = YahooSearch.find(ticker, %w(n x))
    hash = Hash[results[0].zip(results[1])]

    ImportPriceData.perform_later(hash['symbol'], period: 'all')

    Security.new(
      ticker: hash['symbol'],
      track: true,
      name: hash['name'],
      currency: currency_from_exchange(hash['stock exchange']),
      business_id: business_id,
      custom: { stock_exchange: hash['stock exchange'] },
    )
  end

  def self.currency_from_exchange(exchange)
    case exchange
    when 'ASX'
      'AUD'
    else
      'USD'
    end
  end
end
