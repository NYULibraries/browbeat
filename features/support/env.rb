require 'figs'; Figs.load()
require 'capybara/cucumber'
require 'capybara/poltergeist'
require 'capybara'
require 'rspec'
require 'pry'

# add project directory to load path
project_dir = File.expand_path(File.join(File.dirname(__FILE__), '../..'))
$LOAD_PATH.unshift(project_dir) unless $LOAD_PATH.include?(project_dir)

# Require and include helper modules
# in feature/support/helpers and its subdirectories.
Dir["features/support/helpers/**/*.rb"].each do |helper|
  require "#{helper}"
  helper_name = "Browbeat::#{File.basename(helper).split('.')[0].split('_').map(&:capitalize).join('')}"
  World(Kernel.const_get(helper_name))
end
