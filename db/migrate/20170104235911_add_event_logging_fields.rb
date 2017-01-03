class AddEventLoggingFields < ActiveRecord::Migration[5.0]
  def change
    add_column :events, :object_type, :string, null: false
    add_column :events, :parent_id, :integer, index: true
  end
end
