class FieldsController < ApplicationController
  def new
    @field = FieldForm.new(config_params)
  end

  def create
    @field = FieldForm.new(field_params)
    if @field.valid?
      update_config(@field)
      redirect_to config_path(tab: 'portfolios', anchor: "portfolio-#{portfolio.id}")
    else
      render :new
    end
  end

  private

  def config_params
    hash = params[:field_form] || params
    {
      object_id: hash.fetch(:object_id),
      object_type: hash.fetch(:object_type),
      config_type: CustomConfig::FIELDS,
    }
  end

  def field_params
    params
      .require(:field_form)
      .permit(
        :object_id,
        :object_type,
        :name,
        :type,
        :default,
        :validates_presence,
      )
  end

  def update_config(field)
    new_portfolio = portfolio.trades.any? ? clone_portfolio(portfolio) : portfolio

    custom_config = custom_config(new_portfolio)
    custom_config.config ||= {}
    custom_config.config.merge!(field.as_json)
    save_with_events(custom_config)
  end

  def custom_config(portfolio)
    CustomConfig.find_or_initialize_by(
      object_id: portfolio.id,
      object_type: 'Portfolio',
      config_type: CustomConfig::FIELDS,
    )
  end

  def portfolio
    @portfolio ||= Portfolio.find(config_params[:object_id])
  end

  def clone_portfolio(portfolio)
    new_portfolio = portfolio.dup
    new_portfolio.version += 1
    portfolio.update!(current: false)
    new_portfolio.save!

    CustomConfig.where(object_id: portfolio.id, object_type: 'Portfolio').each do |config|
      new_config = config.dup
      new_config.object_id = new_portfolio.id
      new_config.save!
    end
    new_portfolio
  end
end
