FactoryGirl.define do
  factory :business do
    name 'Main Business'

    trait :with_config do
      after(:create) { |b| CustomConfig.create_for(b) }
    end
  end
end
