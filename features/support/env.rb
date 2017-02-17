require 'figs'; Figs.load()
require 'capybara/cucumber'
require 'capybara/poltergeist'
require 'capybara'
require 'selenium/webdriver'
require 'rspec'
require 'pry'
require 'yaml'
require 'browbeat'

if ENV['SCREENSHOT_FAILURES']
  require 'capybara-screenshot/cucumber'

  Capybara::Screenshot.register_filename_prefix_formatter(:cucumber) do |cucumber_scenario|
    scenario = Browbeat::Scenario.new(cucumber_scenario)
    "screenshot_#{scenario.name.downcase.gsub(' ', '_')}"
  end
end

# add project directory to load path
project_dir = File.expand_path(File.join(File.dirname(__FILE__), '../..'))
$LOAD_PATH.unshift(project_dir) unless $LOAD_PATH.include?(project_dir)

# converts full helper path to browbeat helper name
def constantize_helper_path(helper_path)
  camelized_basename = File.basename(helper_path).gsub(/\.rb$/, '').split('_').map(&:capitalize).join
  Kernel.const_get "Browbeat::#{camelized_basename}"
end

# Require and include helper modules
# in feature/support/helpers and its subdirectories.
Dir["features/support/helpers/**/*.rb"].each do |helper_path|
  require helper_path
  World constantize_helper_path helper_path
end

Figs.load()
