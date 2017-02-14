namespace :transfer do # rubocop:disable Metrics/BlockLength
  desc 'Transfer portfolio to  different business'
  task :portfolio, [:portfolio_uid, :business_id] => :environment do |_t, args| # rubocop:disable Metrics/BlockLength
    portfolios = Portfolio.unscoped.where(uid: args[:portfolio_uid])
    old_business = portfolios.first.business
    raise 'Unknown portfolio' if portfolios.empty?
    business = Business.find(args[:business_id])
    raise 'Transfer not needed' if portfolios.last.business == business

    ActiveRecord::Base.connection.transaction do # rubocop:disable Metrics/BlockLength
      # securities
      securities = Trade.where(portfolio_id: portfolios).distinct.pluck(:security_id)
      sec_mappings = Hash[
        securities.map do |security_id|
          old_sec = Security.find(security_id)
          next if Security.find_by(ticker: old_sec.ticker, business_id: business.id)

          puts "Creating new version of security: #{old_sec.ticker}"
          new_sec = Security.create(
            old_sec.attributes.except('id', 'created_at', 'updated_at').merge(business_id: business.id),
          )
          [old_sec.id, new_sec.id]
        end.compact
      ]

      # portfolio
      portfolios.each do |portfolio|
        puts "Transfer portfolio version: #{portfolio.version}"

        portfolio.business_id = business.id
        portfolio.save!(validate: false)
      end

      # events
      Event.where(portfolio_uid: portfolios.last.uid).each do |event|
        puts "Transfer event: #{event.id}"

        event.business_id = business.id
        event.save!(validate: false)
      end

      # security in trade
      Trade.where(portfolio_id: portfolios, security_id: sec_mappings.keys).each do |trade|
        puts "Updating security on trade: #{trade.uid}"

        trade.security_id = sec_mappings[trade.security_id]
        trade.save!(validate: false)
      end

      SharedPortfolio.create!(portfolio_uid: portfolios.first.uid, business: old_business)
    end
  end
end
