class YahooSecuritySearchesController < ApplicationController
  def show
    params[:ticker] = params[:ticker].split(/[, ]+/).uniq.reject(&:blank?).compact.join(',').upcase
    if params[:fields]
      @fields = params[:fields]
      session['yahoo_search_params'] = @fields.to_json if @fields.any?
    else
      @fields = JSON.parse(session['yahoo_search_params'])
    end
    if params[:ticker]
      @security = YahooSearch.find(params[:ticker], @fields)
    end
  end
end
