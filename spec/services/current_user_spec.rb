require 'rails_helper'

RSpec.describe CurrentUser do
  let(:user) { double(:user, oauth_expires_at: 1.week.from_now) }
  let(:controller) { double(:controller, session: {}) }
  let(:fake_finder) { double(:finder, get: user) }

  context 'when using a custom finder' do
    it 'returns the get method of the custom finder' do
      described_class.finder = fake_finder
      expect(described_class.get(controller)).to eq(user)
      described_class.finder = nil
    end
  end

  context 'when using the default finder' do
    before do
      controller.session[:user_id] = 123
      allow(User).to receive(:find).and_return(user)
    end

    it 'will attempt to find the user by ID' do
      expect(User).to receive(:find).with(123)
      described_class.get(controller)
    end

    it 'wil return the user if he auth token has not expired' do
      expect(described_class.get(controller)).to eq(user)
    end

    it 'wil return nil if he auth token has expired' do
      allow(user).to receive(:oauth_expires_at).and_return(1.day.ago)
      expect(described_class.get(controller)).to be_nil
    end
  end
end
