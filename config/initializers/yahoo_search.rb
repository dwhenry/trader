YahooSearch.api = if ENV['YAHOO_SEARCH_ENABLED']
                    YahooSearch::Api
                  else
                    YahooSearch::StubApi
                  end
