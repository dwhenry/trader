class CreateBackoffices < ActiveRecord::Migration[5.0]
  def change
    create_table :backoffices do |t|
      t.string :trade_uid, null: false, index: true
      t.integer :trade_version, null: false, index: true
      t.string :state, null: false
      t.date :settlement_date
      t.integer :version, default: 1, null: false
      t.boolean :current, default: true, null: false
      t.jsonb :custom

      t.timestamps
    end
  end
end
