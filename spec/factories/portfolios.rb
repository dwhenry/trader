FactoryGirl.define do
  factory :portfolio do
    uid { SecureRandom.uuid }
    name 'Main Portfolio'
  end
end
