class CreateSecurities < ActiveRecord::Migration[5.0]
  def change
    create_table :securities do |t|
      t.string :name
      t.string :ticker
      t.string :currency
      t.jsonb :custom

      t.timestamps
    end
  end
end
