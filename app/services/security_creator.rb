class SecurityCreator
  class UnknownExchange < StandardError; end

  def self.from_yahoo(business_id, ticker) # rubocop:disable Metrics/MethodLength
    results = YahooSearch.find(ticker, %w(x))
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
    when 'ASE' then 'USD' # American Stock Exchange
    when 'ASX' then 'AUD' # Australian Stock Exchange
    when 'FRA' then 'EUR' # Frankfurt - Frankfurt Delayed Price.
    when 'HKG' then 'HKD' # HKSE - HKSE Delayed Price.
    when 'LSE' then 'GBP' # London
    when 'NMS' then 'USD' # NasdaqGS - NasdaqGS Real Time Price
    when 'NYQ' then 'USD' # NYSE - NYSE Delayed Price
    when 'PAR' then 'EUR' # Paris - Paris Delayed Price.
    when 'PCX' then 'USD' # NYSEArca - NYSEArca Delayed Price
    when 'STO' then 'SEK' # Stockholm - Stockholm Delayed Price
    when 'SES' then 'SGD' # SES - SES Delayed Price
    when 'TLO' then 'USD' # TLO - TLO Delayed Price
    else
      raise UnknownExchange, exchange
    end
  end
end
