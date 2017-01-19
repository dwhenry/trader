require 'rails_helper'

RSpec.feature 'Adding a security' do
  scenario 'can add a new security', vcr: true do
    user = create(:user, business: create(:business))

    with_yahoo_finance_data do
      with_user(user) do
        given_i_search_for_a_security
        when_i_add_the_security_for_tracking
        then_the_security_is_be_tracked_going_forward
        # and_historical_price_data_has_been_imported
      end
    end
  end

  def given_i_search_for_a_security
    @page = SecuritySearchPage.new
    @page.load

    @page.ticker.set('goog')
    @page.search.click
  end

  def when_i_add_the_security_for_tracking
    security = @page.securities.first
    security.tracking.click
  end

  def then_the_security_is_be_tracked_going_forward
    security = Security.first
    expect(security).to have_attributes(
      ticker: 'GOOG',
      name: 'Alphabet Inc.',
      track: true,
      currency: 'USD',
      custom: { 'stock_exchange' => 'NMS' },
    )
  end

  # def and_historical_price_data_has_been_imported
  #   security = Security.first
  #   expect(security.prices).not_to be_empty
  # end
end
