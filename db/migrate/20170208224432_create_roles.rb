class CreateRoles < ActiveRecord::Migration[5.0]
  def change
    create_table :roles do |t|
      t.string :name
      t.references :business, foreign_key: true

      t.timestamps
    end

    remove_column :users, :role, :string
    add_column :users, :role_id, :integer
  end
end
