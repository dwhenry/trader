require 'rails_helper'

RSpec.describe Trade do
  let!(:trade) { create(:trade, :fully_setup) }

  it 'can only have a single current trade for a given UID' do
    new_trade = build_stubbed(
      :trade,
      security: trade.security,
      portfolio: trade.portfolio,
      uid: trade.uid,
      current: true
    )
    expect(new_trade).not_to be_valid
  end

  it 'have two current trades for different UIDs' do
    new_trade = build_stubbed(
      :trade,
      security: trade.security,
      portfolio: trade.portfolio,
      current: true
    )
    expect(new_trade).to be_valid
  end
end
