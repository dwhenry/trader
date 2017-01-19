class YahooSecuritySearchesController < ApplicationController
  DEFAULT_FIELDS = %w(a b n).freeze

  def show
    @fields = params[:fields] = remember_fields(params[:fields])

    return unless params[:ticker]

    params[:ticker] = clean_ticker(params[:ticker])
    @headers, *@securities = *YahooSearch.find(params[:ticker], @fields)
  end

  private

  def remember_fields(fields)
    session['yahoo_search_params'] = fields if fields&.any?
    session['yahoo_search_params'] || DEFAULT_FIELDS
  end

  def clean_ticker(ticker)
    ticker.split(/[, ]+/).uniq.reject(&:blank?).compact.join(',').upcase
  end
end
