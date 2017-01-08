module ApplicationHelper
  def config_tab_options
    { 'business' => 'Business', 'user' => 'User', 'portfolios' => "Portfolio's" }
  end

  def configuration_options
    [['Use default options', 0]] + Portfolio.where(business_id: current_user.business_id).pluck(:name, :id)
  end
end
