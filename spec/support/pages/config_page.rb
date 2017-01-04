class ConfigPage < SitePrism::Page
  set_url '/config'

  element :business_name, '.t-business-name'
  element :reporting_currency, '.t-reporting-currency'

  element :user_name, '.t-user-name'
  element :emails, '.t-emails'
  element :add, '.t-add'

  element :portfolio_name, '.t-portfolio-name'
  element :allow_negative_positions, '.t-allow-negative-positions-yes'

  element :save, '.t-save'

  elements :tabs, '.t-tab'

  def tab(tab_name)
    tabs.detect { |tab| tab.text.downcase == tab_name.to_s }.click
  end
end
