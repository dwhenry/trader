class AddCurrencyToBusiness < ActiveRecord::Migration[5.0]
  def up
    add_column :businesses, :reporting_currency, :string

    Business.all.each do |b|
      config = CustomConfig.find_for(b)
      b.update! reporting_currency: config.config_instance.reporting_currency
      config.config.delete('reporting_currency')
      if config.config.empty?
        config.delete
      else
        config.save!
      end
    end
  end

  def down
    Business.all.each do |b|
      config = CustomConfig.find_or_initialize_for(b)
      config.config ||= {}
      config.config['reporting_currency'] = b.reporting_currency
      config.save!
    end

    remove_column :businesses, :reporting_currency
  end
end
