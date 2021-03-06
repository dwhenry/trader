class YahooSecuritySearchesController < ApplicationController
  DEFAULT_FIELDS = %w(a b).freeze

  def show
    authorize :yahoo_search
    @fields = remembered_fields

    return unless params[:ticker]

    params[:ticker] = clean_ticker(params[:ticker])
    @headers, *@securities = *YahooSearch.find(params[:ticker], @fields) if params[:ticker].present?
  end

  private

  def remembered_fields
    fields = params[:fields]
    session['yahoo_search_params'] = fields if fields&.any?
    params[:fields] = session['yahoo_search_params'] || DEFAULT_FIELDS
  end

  def clean_ticker(ticker)
    ticker.split(/[, ]+/).uniq.reject(&:blank?).compact.join(',').upcase
  end
end
