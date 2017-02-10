class Nav < SimpleDelegator
  def self.nav(page)
    new(page).nav
  end

  def nav
    if current_user && current_user.role
      nav = items
      nav.flatten.each do |item|
        item.current = true if current_page?(item.path)
      end
      nav.children
    else
      [Item.new(name: 'Business', path: business_path, icon: 'home')]
    end
  end

  private

  def items
    Item.new(
      children: [
        Item.new(name: 'Business', path: business_path, icon: 'home'),
        Item.new(name: 'Portfolio\'s', icon: 'th-large', children: portfolios),
        Item.new(name: 'Securities', icon: 'bar-chart', children: securities),
        policy(self).configure_system? &&  Item.new(name: 'Configure', path: config_path, icon: 'gear'),
      ],
    )
  end

  def portfolios
    Portfolio.where(business_id: current_user.business_id).map do |portfolio|
      Item.new(name: portfolio.name, path: portfolio_path(portfolio))
    end
  end

  def securities
    add_security = Item.new(name: 'Add', path: yahoo_security_search_path, icon: 'pencil-square-o')
    [policy(self).follow_security? && add_security] +
      Security.where(business_id: current_user.business_id).map do |security|
        Item.new(name: security.name, path: security_path(security))
      end
  end

  class Item
    attr_reader :name, :path, :icon, :children
    attr_writer :current

    def initialize(name: nil, path: nil, icon: nil, children: [])
      @name = name
      @path = path
      @icon = icon
      @children = children.compact
    end

    def flatten
      children.any? ? children.flat_map(&:flatten) : [self]
    end

    def current?
      @current || children.any?(&:current?)
    end
  end
end
