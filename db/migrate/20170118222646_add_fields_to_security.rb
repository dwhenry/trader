class AddFieldsToSecurity < ActiveRecord::Migration[5.0]
  def change
    add_column :securities, :track, :boolean, default: true, null: false
    add_column :securities, :business_id, :integer, null: false, index: true
  end
end
