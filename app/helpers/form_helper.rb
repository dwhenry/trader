module FormHelper
  def field(f, field_name: , hint: nil, &block)
    errors = f.object.errors[field_name].join('<br>').presence
    render 'form/field', hint: hint, error: errors, block: block
  end

  def field_tag(value:, error_proc:, hint: nil, &block)
    errors = error_proc.call(value)
    render 'form/field', hint: hint, error: errors, block: block
  end
end
