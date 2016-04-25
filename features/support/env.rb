require 'figs'; Figs.load()
require 'capybara/cucumber'
require 'capybara/poltergeist'
require 'capybara'
require 'rspec'
require 'pry'

# Require and include helper modules
# in feature/support/helpers and its subdirectories.
Dir["features/support/helpers/**/*.rb"].each do |helper|
  require_relative "../../#{helper}"
  helper_name = "Browbeat::#{File.basename(helper).split('.')[0].split('_').map(&:capitalize).join('')}"
  World(Kernel.const_get(helper_name))
end
