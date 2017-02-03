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
    if portfolio.trades.any?
      # clone portfolio
      raise 'not here'
    else
      custom_config.config ||= {}
      custom_config.config.merge!(field.as_json)
      save_with_events(custom_config)
    end
  end

  def custom_config
    @custom_config ||= CustomConfig.find_or_initialize_by(config_params)
  end

  def portfolio
    @portfolio ||= custom_config.object
  end
end
