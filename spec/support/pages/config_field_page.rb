class ConfigFieldPage < SitePrism::Page
  element :name, '.t-name'
  elements :type_options, '.t-type'
  element :default, '.t-default'

  element :validates_presence, '.t-validates-presence'

  element :save, '.t-save-button'

  def type=(type)
    type_options.detect { |type_option| type_option['value'] == type }.set(true)
  end

  def add_fruit_field
    name.set('Fruit field')
    self.type = 'string'
    validates_presence.set(true)
    default.set('apples')
    save.click
  end
end
