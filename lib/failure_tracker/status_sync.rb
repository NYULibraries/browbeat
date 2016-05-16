module FailureTracker
  class StatusSync
    attr_accessor :failed_scenario_collection

    SUCCESS_STATUS_TYPE = 'operational'

    def self.sync_status_page(failed_scenario_collection)
      new(failed_scenario_collection).sync_status_page
    end

    def initialize(failed_scenario_collection)
      @failed_scenario_collection = failed_scenario_collection
    end

    def sync_status_page
      Application.list_all.each do |application|
        application.set_status_page_status status_for_application(application)
      end
    end

    def status_for_application(application)
      app_failures = failed_scenarios_for_application application
      app_failures.any? ? app_failures.worst_failure_type : SUCCESS_STATUS_TYPE
    end

    def failed_scenarios_for_application(application)
      failed_production_scenarios.select{|s| s.app_symbol == application.symbol }
    end

    def failed_production_scenarios
      @failed_production_scenarios ||= failed_scenario_collection.with_tags(:production)
    end
  end
end
