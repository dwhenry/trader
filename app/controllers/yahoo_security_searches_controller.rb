class YahooSecuritySearchesController < ApplicationController
  def show
    if params[:fields]
      @fields = params[:fields].select { |_, v| v == '1' }.permit!.to_h
      session['yahoo_search_params'] = @fields.to_json if @fields.any?
    else
      @fields = JSON.parse(session['yahoo_search_params'])
    end
    if params[:ticker]
      @security = YahooSearch.find(params[:ticker], @fields.keys)
    end
  end
end
