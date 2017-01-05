class AddObjectIdToEvents < ActiveRecord::Migration[5.0]
  def change
    add_column :events, :object_id, :integer
    remove_column :events, :trade_id
    add_column :events, :trade_uid, :string, index: true
  end
end
