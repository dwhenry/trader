class User < ApplicationRecord
  belongs_to :business, required: false
  validates :email, uniqueness: true

  def self.from_omniauth(auth) # rubocop:disable Metrics/AbcSize
    user = find_by(provider: auth.provider, uid: auth.uid) ||
      find_by(email: auth.info.email, uid: nil) ||
      create(
        provider: auth.provider,
        uid: auth.uid,
        name: auth.info.name,
        email: auth.info.email,
        oauth_token: auth.credentials.token,
        oauth_expires_at: Time.zone.at(auth.credentials.expires_at),
      )
    user.update(
      oauth_token: auth.credentials.token,
      oauth_expires_at: Time.zone.at(auth.credentials.expires_at),
    )
    user
  end
end
