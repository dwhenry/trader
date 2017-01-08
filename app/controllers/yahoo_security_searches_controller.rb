class YahooSecuritySearchesController < ApplicationController
  def show
    if params[:fields]
      @fields = params[:fields]
      session['yahoo_search_params'] = @fields.to_json if @fields.any?
    else
      @fields = JSON.parse(session['yahoo_search_params'])
    end

    return unless params[:ticker]

    params[:ticker] = params[:ticker].split(/[, ]+/).uniq.reject(&:blank?).compact.join(',').upcase
    @security = YahooSearch.find(params[:ticker], @fields)
  end
end
