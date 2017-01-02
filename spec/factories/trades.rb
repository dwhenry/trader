FactoryGirl.define do
  factory :trade do
    quantity '10'
    price '10.01'
    currency 'AUD'
    uid { Trade.next_uid }
    date { Time.zone.today }
  end

  trait :fully_setup do
    portfolio { create(:portfolio, business: create(:business)) }
    security { create(:security) }
  end
end
