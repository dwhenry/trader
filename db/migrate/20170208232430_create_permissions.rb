class CreatePermissions < ActiveRecord::Migration[5.0]
  def change
    create_table :permissions do |t|
      t.string :name
      t.references :role, foreign_key: true

      t.timestamps
    end

    Role.create!(name: Role::SUPER_ADMIN)
    Business.all.each do |business|
      admin = Role.default_roles(business).each(&:save!).first
      User.where(business_id: business.id).each { |user| user.update(role: admin) }
    end
  end
end
