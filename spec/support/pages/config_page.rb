class ConfigPage < SitePrism::Page
  set_url '/config'

  elements :tabs, '.t-tab'

  element :business_name, '.t-business-name'
  element :reporting_currency, '.t-reporting-currency'

  element :user_name, '.t-user-name'
  element :emails, '.t-emails'

  sections :portfolios, '.t-portfolio' do
    element :portfolio_name, '.t-portfolio-name'
    element :allow_negative_positions, '.t-allow-negative-positions-yes'

    element :save, '.t-save'
    element :add_field, '.t-add-field-config'
  end

  element :new_portfolio_name, '.t-new-portfolio-name'

  element :save, '.t-save'
  element :add, '.t-add'

  def tab(tab_name)
    tabs.detect { |tab| tab.text.downcase == tab_name.to_s }.click
  end
end
