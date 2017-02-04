require 'rails_helper'

RSpec.describe Portfolio do
  let(:business) { create(:business) }
  it 'multiple non-current portfolios can exist with the same name' do
    create(:portfolio, current: false, business: business, name: 'john')
    create(:portfolio, current: false, business: business, name: 'john')
  end

  it 'multiple current portfolios can exist with different names' do
    create(:portfolio, current: true, business: business, name: 'john')
    create(:portfolio, current: true, business: business, name: 'bob')
  end

  it 'multiple current portfolios can not exist with the same names' do
    create(:portfolio, current: true, business: business, name: 'john')
    expect do
      create(:portfolio, current: true, business: business, name: 'john')
    end.to raise_error(ActiveRecord::RecordInvalid)
  end
end
