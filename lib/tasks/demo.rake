namespace :demo do
  desc 'Load in some example trades - NOTE: replace , with ; in JSON because rake sucks arse'
  task :load, [:security_json] => :environment do |_t, args|
    require 'demo_builder'

    portfolio = Portfolio.find_by!(name: 'Example')

    builder = DemoBuilder.new(User.find_by!(business_id: portfolio.business_id))

    security_values = JSON.parse(args[:security_json].tr(';', ','))

    Trade.joins(:portfolio).where(portfolios: { business_id: portfolio.business_id }).delete_all
    Security.where(business_id: portfolio.business_id).delete_all

    security_values.keys.each do |ticker|
      security = builder.security(ticker, portfolio.business_id)
      if security.blank?
        puts "Skipping: #{ticker} as could not be found on yahoo"
        next
      end
      final = (security_values[security.ticker].to_i / builder.close_price(ticker, Time.zone.today))
      builder.trade(
        security,
        portfolio,
        final.ceil,
      )
    end
  end
end
