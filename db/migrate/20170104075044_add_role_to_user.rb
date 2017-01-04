class AddRoleToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :role, :string

    User.update_all(role: 'admin')

    change_column :users, :role, :string, null: false
  end
end
