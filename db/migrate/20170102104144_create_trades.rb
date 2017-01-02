class CreateTrades < ActiveRecord::Migration[5.0]
  def change
    create_table :trades do |t|
      t.integer :quantity
      t.decimal :price
      t.string :currency
      t.date :date
      t.references :security, foreign_key: true
      t.references :portfolio, foreign_key: true
      t.jsonb :custom

      t.timestamps
    end
  end
end
