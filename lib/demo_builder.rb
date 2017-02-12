class DemoBuilder
  include SaveWithVersions
  attr_reader :current_user

  def initialize(current_user)
    @current_user = current_user
  end

  def security(ticker, business_id)
    puts "creating security for #{ticker}"
    security = Security.find_by(ticker: ticker, business_id: business_id)
    return security if security
    if YahooSearch.find(ticker, %w(x)).count > 1 # 1 header + 1 data rows
      SecurityCreator.from_yahoo(business_id, ticker).tap(&:save!)
    end
  end

  def trade(security, portfolio, final)
    puts "building trades for #{security.ticker}"
    quantities = quantities(final.to_i)
    dates = dates(quantities.count)
    dates.zip(quantities).each do |offset, quantity|
      trade = Trade.new(uid: Trade.next_uid)
      save_with_versions(
        trade => {
          portfolio_id: portfolio.id,
          date: offset.days.ago,
          quantity: quantity,
          price: close_price(security.ticker, offset.days.ago),
          currency: security.currency,
          security_id: security.id,
        }
      )

      # 90% chance of having been settled
      if rand < 0.9
        save_with_versions(trade => {}, trade.backoffice => { state: 'settled' })
      end
    end
  end

  # randomly(ish) split the dates of the trades to reach the final position.
  def dates(count)
    max = rand(100) + (count * 20)
    intervals = count.times.map { rand }
    sum = intervals.inject(:+)
    intervals.map! { |v| (max * (v / sum)) }
    offset = max - intervals.inject(:+)
    intervals[-1] += offset
    intervals
  end

  # this is a bit of a crazy equation that doesn't quite work, but is close enough that it doesn't matter for
  # generating some random data
  def quantities(final)
    # determine the number of trades to reach the final quantity
    trades = rand(5) + 2
    quantities = []
    if trades == 1
      quantities << final
    else
      # add a start value # which must be positive
      quantities << rand(final * 3)

      # add some random values which can be positive or negative
      (trades - 2).times do
        quantities << (rand(final * 2) - final) # need to allow negative sum of quantity.
      end
      # determine final value
      sum = final - quantities.inject(:+)

      if sum.abs < final * 2 # if the final value is inside normal ranges
        quantities << sum
      else # try and adjust the final value to be inside normal ranges - this doesn't quite work, not sure why?
        quantities.map! { |val| ((val - final) * (final * 2) / sum) + final }
        sum = final - quantities.inject(:+)
        quantities << sum
      end
    end
    quantities.reject { |val| val == 0 } # just cause its a thing..
  end

  def close_price(ticker, date)
    price = Price.where(ticker: ticker).where(['date < ?', date]).order('date desc').first
    price&.close || 1
  end
end
