class VersionPortfolio < ActiveRecord::Migration[5.0]
  class LocalPortfolio < ActiveRecord::Base
    self.table_name = 'portfolios'
  end

  def change
    add_column :portfolios, :uid, :string
    add_column :portfolios, :version, :integer, default: 1, null: false
    add_column :portfolios, :current, :boolean, default: true, null: false

    LocalPortfolio.all.each do |portfolio|
      portfolio.uid = SecureRandom.uuid
      portfolio.save!
    end

    change_column :portfolios, :uid, :string, null: false
  end
end
