class FieldsController < ApplicationController
  def new
    @field = FieldForm.new(config_params)
  end

  def create
    @field = FieldForm.new(field_params)
    if @field.valid?
      custom_config_for_editing(portfolio, @field.config_type) do |config|
        config.merge!(@field.as_json)
      end
      redirect_to config_path(tab: 'portfolios', anchor: "portfolio-#{portfolio.id}")
    else
      render :new
    end
  end

  def edit
    custom_config = CustomConfig.find(params[:id])
    key = params.fetch(:key)
    @field = FieldForm.new(custom_config.config.fetch(key).merge(config_type: custom_config.config_type))
    render :new
  end

  def destroy
    base_custom_config = CustomConfig.find(params[:id])
    key = params.fetch(:key)
    if base_custom_config.config.key?(key)
      custom_config_for_editing(base_custom_config.owner, base_custom_config.config_type) do |config|
        config.delete(key)
      end
    end
    redirect_to config_path(tab: 'portfolios')
  end

  private

  def config_params
    hash = params[:field_form] || params
    {
      owner_id: hash.fetch(:owner_id),
      owner_type: hash.fetch(:owner_type),
      config_type: CustomConfig::TRADE_FIELDS,
    }
  end

  def field_params # rubocop:disable Metrics/MethodLength
    params
      .require(:field_form)
      .permit(
        :owner_id,
        :owner_type,
        :config_type,
        :name,
        :type,
        :values,
        :default,
        :validates_presence,
        :validates_inclusion,
      )
  end

  def custom_config_for_editing(portfolio, config_type)
    new_portfolio = portfolio.trades.any? ? clone_portfolio(portfolio) : portfolio

    custom_config = custom_config(new_portfolio, config_type)
    custom_config.config ||= {}
    yield custom_config.config
    save_with_events(custom_config)
  end

  def custom_config(portfolio, config_type)
    CustomConfig.find_or_initialize_by(
      owner_id: portfolio.id,
      owner_type: 'Portfolio',
      config_type: config_type,
    )
  end

  def portfolio
    @portfolio ||= Portfolio.find(config_params[:owner_id])
  end

  def clone_portfolio(portfolio)
    new_portfolio = portfolio.dup
    new_portfolio.version += 1
    portfolio.update!(current: false)
    new_portfolio.save!

    CustomConfig.where(owner_id: portfolio.id, owner_type: 'Portfolio').each do |config|
      new_config = config.dup
      new_config.owner_id = new_portfolio.id
      new_config.save!
    end
    new_portfolio
  end
end
