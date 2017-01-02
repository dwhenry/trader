class BusinessesController < ApplicationController
  before_action :require_user

  def show
    render text: 'here'
  end
end
