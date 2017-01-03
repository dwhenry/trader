class TradeEdit
  FIELDS = %i(
    uid
    date
    quantity
    price
    currency
    portfolio_id
    security_id
  ).freeze

  def initialize(params)
    @current_trade = Trade.find_by!(uid: params[:uid])
    @new_trade = Trade.new(params)
  end

  attr_reader :new_trade
  delegate :uid, :portfolio, to: :new_trade

  def unchanged?
    FIELDS.all? do |field|
      @current_trade[field] == @new_trade[field]
    end
  end

  def save
    ApplicationRecord.transaction do
      begin
        return _save!
      rescue
        raise ActiveRecord::Rollback
      end
    end
    @new_trade.current = false
    valid? # ensure new trade has validation failures
    false
  end

  def _save!
    @current_trade.update!(current: false)
    @new_trade.version = @current_trade.version + 2
    if @new_trade.quantity.positive?
      @new_trade.save!
      make_offset!
    else
      make_offset!
      @new_trade.save!
    end
  end

  def make_offset! # rubocop:disable Metrics/MethodLength
    Trade.create!(
      uid: @current_trade.uid,
      date: @current_trade.date,
      quantity: -@current_trade.quantity,
      price: @current_trade.price,
      currency: @current_trade.currency,
      portfolio_id: @current_trade.portfolio_id,
      security_id: @current_trade.security_id,
      offset_trade: true,
      current: false,
      version: @current_trade.version + 1,
    )
  end
end
