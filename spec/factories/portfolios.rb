FactoryGirl.define do
  factory :portfolio do
    name 'Main Portfolio'

    trait :with_config do
      after(:create) { |p| CustomConfig.create_for(p) }
    end
  end
end
