require 'figs'; Figs.load()
require 'capybara/cucumber'
require 'capybara/poltergeist'
require 'capybara'
require 'rspec'
require 'pry'
require 'sauce/cucumber'

# if flagged to on sauce, set
if ENV["RUN_ON_SAUCE"]
  puts "Running on sauce..."
  Capybara.default_driver = :sauce
  Capybara.javascript_driver = :sauce
# otherwise, use default drivers
else
  puts "Running on default drivers..."
  Capybara.default_driver = :webkit
  Capybara.javascript_driver = :selenium
end

# Require and include helper modules
# in feature/support/helpers and its subdirectories.
Dir["features/support/helpers/**/*.rb"].each do |helper|
  require_relative "../../#{helper}"
  helper_name = "Browbeat::#{File.basename(helper).split('.')[0].split('_').map(&:capitalize).join('')}"
  World(Kernel.const_get(helper_name))
end

# must configure sauce even if not running to avoid errors
Sauce.config do |config|
  # enable sauce-connect
  config[:start_tunnel] = false
  # point to npm-installed sauce-connect 4 executable
  config[:sauce_connect_4_executable] = 'node_modules/sauce-connect/ext/Sauce-Connect.jar'
end
