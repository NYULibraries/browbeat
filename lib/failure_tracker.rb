require 'forwardable'
require 'status_page'
require 'cucumber'
require 'failure_tracker/scenario'
require 'failure_tracker/scenario_collection'
require 'failure_tracker/application'
require 'failure_tracker/status_sync'

module FailureTracker

  def scenarios
    @scenarios ||= ScenarioCollection.new
  end
  module_function :scenarios

  def register_scenario(scenario)
    scenarios << Scenario.new(scenario)
  end
  module_function :register_scenario

  def sync_status_page
    StatusSync.sync_status_page scenarios
  end
  module_function :sync_status_page

end
