class CreateEvents < ActiveRecord::Migration[5.0]
  def change
    create_table :events do |t|
      t.references :trade, foreign_key: true
      t.references :portfolio, foreign_key: true
      t.references :business, foreign_key: true
      t.references :user, foreign_key: true
      t.string :event_type
      t.jsonb :details

      t.timestamps
    end
  end
end
