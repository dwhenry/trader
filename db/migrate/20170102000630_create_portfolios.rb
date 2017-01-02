class CreatePortfolios < ActiveRecord::Migration[5.0]
  def change
    create_table :portfolios do |t|
      t.references :business, foreign_key: true
      t.string :name

      t.timestamps
    end
  end
end
