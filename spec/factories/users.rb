FactoryGirl.define do
  factory :user do
    business nil
    provider 'Google'
    uid { SecureRandom.uuid }
    name 'Primary User'
    email 'primary@user.com'
    oauth_token { SecureRandom.uuid }
    oauth_expires_at { 1.week.from_now }
    role 'admin'
  end
end
