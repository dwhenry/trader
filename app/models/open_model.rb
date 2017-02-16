class OpenModel
  include ActiveModel::Model

  def initialize(params)
    @field_names = params.keys
    setup_attributes
    super(params)
  end

  def each(&block)
    @field_names.each(&block)
  end

  def setup_attributes
    (class << self; self; end).send(:attr_accessor, *@field_names)
    (class << self; self; end).send(:validates, *@field_names, presence: true)
  end
end
