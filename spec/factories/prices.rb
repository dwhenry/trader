FactoryGirl.define do
  factory :price do
    ticker 'MyString'
    date '2017-01-19'
    open '9.99'
    close '9.99'
    high '9.99'
    low '9.99'
    volume 1
    adj_close '9.99'
  end
end
