class AddConfigType < ActiveRecord::Migration[5.0]
  def change
    add_column :custom_configs, :config_type, :string

    CustomConfig.all.each do |config|
      config.config_type = CustomConfig::SETTINGS
      if config.config.is_a?(Array)
        puts "FROM: #{config.config.inspect}"
        config.config = config.config.each_with_object({}) { |c, h| h[c['name']] = c['value'] }
        puts "TO: #{config.config.inspect}"
      end
      config.save
    end

    Business.all.each { |b| CustomConfig.build_for(b).save }
    Portfolio.all.each { |p| CustomConfig.build_for(p).save }
  end
end
