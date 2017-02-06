FactoryGirl.define do
  factory :trade do
    quantity '10'
    price '10.01'
    currency 'AUD'
    uid { Trade.next_uid }
    date { Time.zone.today }

    after(:create) { |trade| Backoffice.create_from!(trade) }

    trait :fully_setup do
      transient do
        business { create(:business, name: 'shared') }
      end
      portfolio { create(:portfolio, business: business) }
      security { create(:security, business: business) }
    end
  end
end
