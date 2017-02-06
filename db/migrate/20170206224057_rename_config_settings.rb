class RenameConfigSettings < ActiveRecord::Migration[5.0]
  def change
    execute <<~SQL
      UPDATE custom_configs
      SET config_type = 'trade_fields'
      WHERE config_type = 'fields'
    SQL
  end
end
