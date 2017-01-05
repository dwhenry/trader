class AddConfigType < ActiveRecord::Migration[5.0]
  def change
    add_column :custom_configs, :config_type, :string
  end
end
