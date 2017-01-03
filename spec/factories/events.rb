FactoryGirl.define do
  factory :event do
    trade nil
    portfolio nil
    business nil
    user nil
    event_type "MyString"
    details ""
  end
end
