class CreateRoles < ActiveRecord::Migration[5.0]
  def change
    create_table :roles do |t|
      t.string :name
      t.references :business, foreign_key: true

      t.timestamps
    end

    role = Role.create!(name: Role::SUPER_ADMIN)

    remove_column :users, :role
    add_column :users, :role_id, :integer, default: role.id
    change_column :users, :role_id, :integer, null: false
  end
end
