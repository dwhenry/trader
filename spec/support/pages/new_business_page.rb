class NewBusinessPage < SitePrism::Page
  set_url '/business/new'

  element :business_name, '.t-business-name'
  element :portfolio_name, '.t-portfolio-name'

  element :save_button, '.t-save-button'

  def setup
    business_name.set 'Bus 1'
    portfolio_name.set 'Port 1'

    save_button.click
  end
end
