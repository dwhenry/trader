class CreateCustomConfigs < ActiveRecord::Migration[5.0]
  def change
    create_table :custom_configs do |t|
      t.string :object_type
      t.string :object_id
      t.jsonb :config

      t.timestamps
    end
  end
end
