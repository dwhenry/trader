require 'rails_helper'

RSpec.describe SessionsController do
  let(:omniauth_details) do
    OpenStruct.new(
      'provider' => 'google_oauth2',
      'uid' => '1111',
      'info' => OpenStruct.new(
        'name' => 'Jim Bob',
        'email' => 'jim@bob.com',
        'first_name' => 'Jim',
        'last_name' => 'Bob',
      ),
      'credentials' => OpenStruct.new(
        'token' => '12345',
        'expires_at' => 1_484_008_988,
        'expires' => true,
      ),
    )
  end

  before do
    @request.env['omniauth.auth'] = omniauth_details
  end

  context 'when a user has logged in previously' do
    let!(:user) { create(:user, uid: '1111', provider: 'google_oauth2') }

    it 'stores the user id in the session' do
      get :create, params: { provider: 'google_oauth2' }
      expect(session[:user_id]).to eq(user.id)
    end

    it 'does not create a new user' do
      expect do
        get :create, params: { provider: 'google_oauth2' }
      end.not_to change { User.count }
    end

    it 'sets the token expiry time' do
      get :create, params: { provider: 'google_oauth2' }
      user.reload
      expect(user.oauth_expires_at).to eq(Time.zone.at(1_484_008_988))
    end
  end

  context 'when no user exists' do
    it 'creates a new user' do
      expect do
        get :create, params: { provider: 'google_oauth2' }
      end.to change { User.count }.by(1)
    end

    it 'stores the new user id in the session' do
      get :create, params: { provider: 'google_oauth2' }
      expect(session[:user_id]).to eq(User.last.id)
    end

    it 'sets the token expiry time' do
      get :create, params: { provider: 'google_oauth2' }
      expect(User.last.oauth_expires_at).to eq(Time.zone.at(1_484_008_988))
    end
  end

  context 'when a user has been created but has never logged in' do
    let!(:user) { create(:user, uid: nil, provider: nil, email: 'jim@bob.com') }

    it 'does not create a new user' do
      expect do
        get :create, params: { provider: 'google_oauth2' }
      end.not_to change { User.count }
    end

    it 'stores the user id in the session' do
      get :create, params: { provider: 'google_oauth2' }
      expect(session[:user_id]).to eq(user.id)
    end

    it 'set the users uid and providers' do
      get :create, params: { provider: 'google_oauth2' }
      user.reload
      expect(user).to have_attributes(uid: '1111', provider: 'google_oauth2')
    end

    it 'sets the token expiry time' do
      get :create, params: { provider: 'google_oauth2' }
      user.reload
      expect(user.oauth_expires_at).to eq(Time.zone.at(1_484_008_988))
    end
  end
end
