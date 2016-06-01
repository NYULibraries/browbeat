module Browbeat
  class StatusSync
    attr_accessor :scenario_collection

    SUCCESS_STATUS_TYPE = 'operational'

    def self.sync_status_page(scenario_collection)
      @previously_failing_component_ids = get_failing_components
      new(scenario_collection).sync_status_page
    end

    def self.previously_failing?(*component_ids)
      component_ids.flatten.any? do |component_id|
        @previously_failing_component_ids.map(&:id).include?(component_id)
      end
    end

    def self.get_failing_components
      component_list = StatusPage::API::ComponentList.new(ENV['STATUS_PAGE_PAGE_ID'])
      component_list.get.to_a.select(&:failing?)
    end

    def initialize(scenario_collection)
      @scenario_collection = scenario_collection
    end

    def sync_status_page
      Application.list_all.each do |application|
        next unless scenarios_for_application? application
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

    def scenarios_for_application?(application)
      production_scenario_symbols.any?{|symbol| symbol == application.symbol }
    end

    def failed_production_scenarios
      @failed_production_scenarios ||= production_scenarios.select(&:failed?)
    end

    private
    def production_scenario_symbols
      @scenario_symbols ||= production_scenarios.map(&:app_symbol).uniq
    end

    def production_scenarios
      @production_scenarios ||= scenario_collection.with_tags(:production)
    end

  end
end
