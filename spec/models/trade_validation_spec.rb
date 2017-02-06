require 'rails_helper'

RSpec.describe Trade do
  context 'when security and portfolio belong to different businesses' do
    let(:security) { create(:security, business: create(:business)) }
    let(:portfolio) { create(:portfolio, business: create(:business)) }

    it 'is not value' do
      trade = build_stubbed(:trade, security: security, portfolio: portfolio)
      expect(trade).not_to be_valid
    end
  end
end
