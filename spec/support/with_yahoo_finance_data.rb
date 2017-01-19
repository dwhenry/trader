module WithYahooFinanceData
  def with_yahoo_finance_data
    api = YahooSearch.api
    YahooSearch.api = YahooSearch::Api

    yield
  ensure
    YahooSearch.api = api
  end
end

RSpec.configure do |config|
  config.include WithYahooFinanceData
end
