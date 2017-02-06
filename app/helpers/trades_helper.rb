module TradesHelper
  def field_for(field, form, options = {})
    case field.type
    when 'string'
      form.text_field field.key, class: "#{options[:class]} form-control"
    when 'number'
      form.text_field field.key, type: 'number', min: 0, step: 1, class: "#{options[:class]} form-control"
    when 'list'
      form.select field.key, options_for_select(field.values), class: "#{options[:class]} form-control"
    end
  end
end
