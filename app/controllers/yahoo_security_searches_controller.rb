class YahooSecuritySearchesController < ApplicationController
  DEFAULT_FIELDS = %w(n b s).freeze

  def show
    @fields = remember_fields(params[:fields])

    return unless params[:ticker]

    params[:ticker] = clean(params[:ticker])
    @security = YahooSearch.find(params[:ticker], @fields)
  end

  private

  def remember_fields(fields)
    session['yahoo_search_params'] = fields if fields.any?
    session['yahoo_search_params'] || DEFAULT_FIELDS
  end

  def clean_ticker(ticker)
    ticker.split(/[, ]+/).uniq.reject(&:blank?).compact.join(',').upcase
  end
end
