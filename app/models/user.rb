class User < ApplicationRecord
  belongs_to :business, required: false
  belongs_to :role, required: false
  validates :email, uniqueness: true
  validates :role, presence: true, if: :business

  def self.from_omniauth(auth)
    user = from_uid(auth) || from_email(auth) || from_auth(auth)
    user.update(
      oauth_token: auth.credentials.token,
      oauth_expires_at: Time.zone.at(auth.credentials.expires_at),
    )
    user
  end

  def self.from_uid(auth)
    find_by(provider: auth.provider, uid: auth.uid)
  end

  def self.from_email(auth)
    user = find_by(email: auth.info.email, uid: nil)
    return nil unless user
    user.attributes = {
      provider: auth.provider,
      uid: auth.uid,
      name: auth.info.name,
      email: auth.info.email,
    }
    user
  end

  def self.from_auth(auth)
    new(
      provider: auth.provider,
      uid: auth.uid,
      name: auth.info.name,
      email: auth.info.email,
    )
  end
end
