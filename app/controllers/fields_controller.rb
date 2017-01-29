class FieldsController < ApplicationController
  def new
    config = CustomConfig.find_by!(config_params)
    @field = FieldForm.new(config_id: config.id)
  end

  class FieldForm
    include ActiveModel::Model

    attr_accessor :config_id, :name, :type, :default
    attr_accessor :validate_presence
  end

  private

  def config_params
    {
      object_id: params.fetch(:object_id),
      object_type: params.fetch(:object_type)
    }
  end
end
