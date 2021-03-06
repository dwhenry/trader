ruby IO.read('.ruby-version').strip

source 'https://rails-assets.org' do
  gem 'rails-assets-tether', '>= 1.1.0'
end

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

source 'https://rubygems.org' do # rubocop:disable Metrics/BlockLength
  gem 'bootstrap', '~> 4.0.0.alpha5'
  gem 'bugsnag'
  gem 'jbuilder', '~> 2.5'
  gem 'jquery-rails'
  gem 'newrelic_rpm'
  gem 'omniauth-google-oauth2'
  gem 'pg'
  gem 'puma', '~> 3.0'
  gem 'pundit'
  gem 'rails', '~> 5.0.1'
  gem 'sass-rails', '~> 5.0'
  gem 'select2-rails'
  gem 'sidekiq'
  gem 'slim'
  gem 'turbolinks', '~> 5'
  gem 'uglifier', '>= 1.3.0'

  group :development, :test do
    gem 'capybara'
    gem 'factory_girl_rails'
    gem 'pry-byebug'
    gem 'rspec-rails'
    gem 'rubocop'
    gem 'site_prism'
    gem 'vcr'
    gem 'webmock'
  end

  group :development do
    gem 'listen', '~> 3.0.5'
    gem 'web-console', '>= 3.3.0'
  end

  # Windows does not include zoneinfo files, so bundle the tzinfo-data gem
  gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
end
