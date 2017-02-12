class AddRoleLevel < ActiveRecord::Migration[5.0]
  def change
    add_column :roles, :level, :integer, default: 0

    execute <<~SQL
      UPDATE roles
      SET level = 1
      WHERE name = 'admin'
    SQL

    execute <<~SQL
      UPDATE roles
      SET level = 2
      WHERE name = 'super_admin'
    SQL
  end
end
