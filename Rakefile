# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

begin
  # Rubocop is not available in envs other than development and test.
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new(:default)
rescue LoadError
end

Rails.application.load_tasks
