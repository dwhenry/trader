class SecuritySearchPage < SitePrism::Page
  set_url '/yahoo_security_search'

  element :ticker, '.t-ticker'
  element :search, '.t-search'

  sections :securities, '.t-security' do
    element :tracking, '.t-tracking'
  end
end
