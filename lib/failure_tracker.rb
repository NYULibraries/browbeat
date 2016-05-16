require 'forwardable'
require 'status_page'
require 'cucumber'
require 'failure_tracker/failed_scenario'
require 'failure_tracker/failed_scenario_collection'
require 'failure_tracker/application'
require 'failure_tracker/status_sync'

module FailureTracker

  def failures
    @@failures ||= FailedScenarioCollection.new
  end
  module_function :failures

  def register_failure(scenario)
    failures << FailedScenario.new(scenario)
  end
  module_function :register_failure

  def sync_status_page
    StatusSync.sync_status_page failures
  end
  module_function :sync_status_page

  # def output_failed_applications
  #   if failures.with_tags(:production).any?
  #     failures.with_tags(:production).group_by(&:app_symbol).each do |app_symbol, app_failures|
  #       puts "Application: #{app_symbol}"
  #       if app_failures.any?
  #         puts " Production: #{app_failures.worst_failure_type}"
  #         app_failures.each do |failure|
  #           puts "  * #{failure.name} (#{failure.backtrace_line})"
  #         end
  #       end
  #     end
  #   else
  #     puts "No production failures detected"
  #   end
  # end
  # module_function :output_failed_applications

end
