namespace :runner do
  desc 'Import price data for all tracked from yesterday'
  task prices_yesterday: :environment do
    Security.where(track: true).uniq.pluck(:ticker).each do |ticker|
      ImportPriceData.perform_later(ticker, 'period' => 'yesterday')
    end
  end

  desc 'Import price data for all tracked from today'
  task prices_today: :environment do
    Security.where(track: true).uniq.pluck(:ticker).each do |ticker|
      ImportPriceData.perform_later(ticker, 'period' => 'today')
    end
  end
end
