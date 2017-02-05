class RenameEventObjectToOwner < ActiveRecord::Migration[5.0]
  def change
    rename_column :custom_configs, :object_id, :owner_id
    rename_column :custom_configs, :object_type, :owner_type

    rename_column :events, :object_id, :owner_id
    rename_column :events, :object_type, :owner_type
  end
end
