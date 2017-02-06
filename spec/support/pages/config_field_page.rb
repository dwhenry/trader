class ConfigFieldPage < SitePrism::Page
  element :name, '.t-name'
  elements :type_options, '.t-type'
  element :default, '.t-default'
  element :values, '.t-values'

  element :validates_presence, '.t-validates-presence'
  element :validates_inclusion, '.t-validates-inclusion'

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

  def add_animal_field
    name.set('Animal field')
    self.type = 'list'
    validates_presence.set(true)
    validates_inclusion.set(true)
    default.set('bear')
    values.set('bear,pig,goat')
    save.click
  end
end
