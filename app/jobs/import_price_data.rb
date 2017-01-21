class ImportPriceData < ApplicationJob
  def perform(ticker, period: 'yesterday')
    price_data = YahooSearch.prices(
      ticker,
      from: from(period),
      to: to(period),
    )

    price_data.each do |price_record|
      find_and_update(ticker, price_record)
    end
  end

  def find_and_update(ticker, price_record)
    Price.find_or_initialize_by(ticker: ticker, date: price_record['Date'])
         .update(
           open: price_record['Open'],
           close: price_record['Close'],
           high: price_record['High'],
           low: price_record['Low'],
           volume: price_record['Volume'],
           adj_close: price_record['Adj Close'],
         )
  end

  private

  def from(period)
    case period.to_s
    when 'all'
      1.year.ago.to_date
    when 'yesterday'
      Date.yesterday
    else
      raise "unknown period: #{period}"
    end
  end

  def to(period)
    case period.to_s
    when 'all', 'yesterday'
      Date.yesterday
    else
      raise "unknown period: #{period}"
    end
  end
end
