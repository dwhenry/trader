FactoryGirl.define do
  factory :user do
    business nil
    provider 'MyString'
    uid 'MyString'
    name 'MyString'
    email 'MyString'
    oauth_token 'MyString'
    oauth_expires_at '2017-01-02 01:42:56'
  end
end
