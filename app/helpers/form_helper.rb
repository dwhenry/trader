module FormHelper
  def field(f, field_name:, hint: nil, &block)
    errors = Array(field_name).flat_map { |fn| f.object.errors[fn] }.uniq.sort.join('<br>').presence
    render 'form/field', hint: hint, error: errors, block: block
  end

  def field_tag(value:, error_proc: ->(_) { nil }, hint: nil, &block)
    errors = error_proc.call(value)
    render 'form/field', hint: hint, error: errors, block: block
  end
end
