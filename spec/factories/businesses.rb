FactoryGirl.define do
  factory :business do
    sequence(:name) { |i| "Main Business - #{i}" }
  end
end
