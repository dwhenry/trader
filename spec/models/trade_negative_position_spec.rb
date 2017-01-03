require 'rails_helper'

RSpec.describe Trade do
  let(:trade) { build_stubbed(:trade, :fully_setup, quantity: -10) }

  context 'when negative positions are allowed' do
    it 'allow negative position trades' do
      expect(trade).to be_valid
    end
  end

  context 'when the portfolio disallows negative positions' do
    before do
      CustomConfig.build_for(trade.portfolio).save
    end

    context 'and no other trades exist' do
      it 'does not allow the trade to be booked' do
        expect(trade).not_to be_valid
        expect(trade.errors[:quantity]).to include('Generates a negative position')
      end
    end

    context 'and an offsetting positive trade exists' do
      before do
        create(:trade, portfolio: trade.portfolio, security: trade.security)
      end

      it 'allows the trade to be booked' do
        expect(trade).to be_valid
      end
    end

    context 'and a partially offsetting positive trade exists' do
      before do
        create(:trade, portfolio: trade.portfolio, security: trade.security, quantity: trade.quantity.abs - 1)
      end

      it 'does not allow the trade to be booked' do
        expect(trade).not_to be_valid
      end
    end
  end
end
