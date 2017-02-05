class TradePortfolioUidOnEvent < ActiveRecord::Migration[5.0]
  def change
    add_column :events, :portfolio_uid, :string, index: true

    execute <<~SQL
      UPDATE events
      SET portfolio_uid = portfolios.uid
      FROM portfolios
      WHERE events.portfolio_id = portfolios.id
    SQL

    remove_column :events, :portfolio_id
  end
end
