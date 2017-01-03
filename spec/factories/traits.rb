FactoryGirl.define do
  trait :with_config do
    after(:create) { |p| CustomConfig.build_for(p).save }
  end
end
