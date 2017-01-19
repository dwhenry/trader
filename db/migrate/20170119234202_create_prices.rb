class CreatePrices < ActiveRecord::Migration[5.0]
  def change
    create_table :prices do |t|
      t.string :ticker, index: true
      t.date :date, index: true
      t.decimal :open
      t.decimal :close
      t.decimal :high
      t.decimal :low
      t.integer :volume
      t.decimal :adj_close

      t.timestamps
    end
  end
end
