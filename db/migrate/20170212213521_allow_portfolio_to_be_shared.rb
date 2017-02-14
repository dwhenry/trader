class AllowPortfolioToBeShared < ActiveRecord::Migration[5.0]
  def change
    create_table :shared_portfolios do |t|
      t.string :portfolio_uid, foreign_key: true, index: true
      t.references :business, foreign_key: true
      t.string :access_level, default: :read

      t.timestamps
    end
  end
end
