require 'csv'
require 'open-uri'

class YahooSearch # rubocop:disable Metrics/ClassLength
  cattr_accessor :api

  class Api
    def self.find(ticker, fields)
      read "http://download.finance.yahoo.com/d/quotes.csv?s=#{ticker}&f=s#{fields.join}"
    end

    def self.read(url, headers = false)
      open url do |f|
        CSV.parse(f, headers: headers)
      end
    end
  end

  class StubApi
    def self.find(*)
      [['N/A', 'N/A', 'Alphabet Inc.', 'GOOG'], ['N/A', 'N/A', 'APPELL PETE CORP', 'APPL']]
    end
  end

  def self.find(ticker, fields)
    results = api.find(ticker, fields)
    [headers(fields)] + results
  end

  def self.headers(fields)
    field_map = FIELDS.values.inject(&:merge)
    fields.map { |f| field_map[f.to_sym] }
  end

  def self.fields
    # as the select fields needs the value then the key..
    FIELDS.map do |group, entries|
      [group, entries.map { |k, v| [v.humanize, k] }]
    end
  end

  FIELDS = {
    'Pricing' => {
      a: 'ask',
      b: 'bid',
      b2: 'ask (realtime)',
      b3: 'bid (realtime)',
      p: 'previous close',
      o: 'open',
    },
    'Dividends' => {
      y: 'dividend yield',
      d: 'dividend per share',
      r1: 'dividend pay date',
      q: 'ex-dividend date',
    },
    'Date' => {
      c1: 'change',
      c: 'change & percentage change',
      c6: 'change (realtime)',
      k2: 'change percent',
      p2: 'change in percent',
      d1: 'last trade date',
      d2: 'trade date',
      t1: 'last trade time',
    },
    'Averages' => {
      c8: 'after hours change',
      c3: 'commission',
      g: 'day’s low',
      h: 'day’s high',
      k1: 'last trade (realtime) with time',
      l: 'last trade (with time)',
      l1: 'last trade (price only)',
      t8: '1 yr target price',
      m5: 'change from 200 day moving average',
      m6: 'percent change from 200 day moving average',
      m7: 'change from 50 day moving average',
      m8: 'percent change from 50 day moving average',
      m3: '50 day moving average',
      m4: '200 day moving average',
    },
    'Misc' => {
      w1: 'day’s value change',
      w4: 'day’s value change (realtime)',
      p1: 'price paid',
      m: 'day’s range',
      m2: 'day’s range (realtime)',
      g1: 'holding gain percent',
      g3: 'annualized gain',
      g4: 'holdings gain',
      g5: 'holdings gain percent (realtime)',
      g6: 'holdings gain (realtime)',
      t7: 'ticker trend',
      t6: 'trade links',
      i5: 'order book (realtime)',
      l2: 'high limit',
      l3: 'low limit',
      v1: 'holdings value',
      v7: 'holdings value (realtime)',
      s6: 'revenue',
    },
    '52 Week Pricing' => {
      k: '52 week high',
      j: '52 week low',
      j5: 'change from 52 week low',
      k4: 'change from 52 week high',
      j6: 'percent change from 52 week low',
      k5: 'percent change from 52 week high',
      w: '52 week range',
    },
    'Symbol Info' => {
      v: 'more info',
      j1: 'market capitalization',
      j3: 'market cap (realtime)',
      f6: 'float shares',
      n: 'name',
      n4: 'notes',
      # s: 'symbol',
      s1: 'shares owned',
      x: 'stock exchange',
      j2: 'shares outstanding',
    },
    'Volume' => {
      v: 'volume',
      a5: 'ask size',
      b6: 'bid size',
      k3: 'last trade size',
      a2: 'average daily volume',
    },
    'Ratios' => {
      e: 'earnings per share',
      e7: 'eps estimate current year',
      e8: 'eps estimate next year',
      e9: 'eps estimate next quarter',
      b4: 'book value',
      j4: 'EBITDA',
      p5: 'price / sales',
      p6: 'price / book',
      r: 'P/E ratio',
      r2: 'P/E ratio (realtime)',
      r5: 'PEG ratio',
      r6: 'price / eps estimate current year',
      r7: 'price /eps estimate next year',
      s7: 'short ratio',
    },
  }.freeze
end
