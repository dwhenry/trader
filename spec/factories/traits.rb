FactoryGirl.define do
  trait :with_config do
    after(:create) { |p| ConfigBuilder.new(p) }
  end
end
