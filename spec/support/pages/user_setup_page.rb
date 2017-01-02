class UserSetupPage < SitePrism::Page
  set_url '/user_setup/new'

  element :business_name, '.t-business-name'
  element :portfolio_name, '.t-portfolio-name'

  element :next_button, '.t-next-button'
  element :save_button, '.t-save-button'

  def setup
    business_name.set 'Bus 1'
    portfolio_name.set 'Port 1'

    next_button.click
    # business config page
    next_button.click
    # portfolio config page
    save_button.click
  end
end
