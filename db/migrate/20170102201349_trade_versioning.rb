class TradeVersioning < ActiveRecord::Migration[5.0]
  def change
    add_column :trades, :version, :integer, default: 1, null: false
    add_column :trades, :uid, :string, default: '', null: false
    add_column :trades, :current, :boolean, default: true, null: false
    add_column :trades, :offset_trade, :boolean, default: false, null: false

    Trade.update_all(version: 1, current: true)
    Trade.all.each { |trade| trade.update(uid: Trade.next_uid) }
  end
end
