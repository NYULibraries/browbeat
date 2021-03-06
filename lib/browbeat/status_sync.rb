module Browbeat
  class StatusSync
    extend Helpers::ApiPageIdsHelper

    attr_accessor :scenario_collection, :application_collection

    SUCCESS_STATUS_TYPE = 'operational'
    FAILURE_STATUS_TYPES = %w[major_outage partial_outage degraded_performance]

    def self.sync_status_page(scenario_collection, application_collection)
      new(scenario_collection, application_collection).sync_status_page
    end

    def initialize(scenario_collection, application_collection)
      @scenario_collection = scenario_collection
      @application_collection = application_collection
    end

    def sync_status_page
      application_collection.each do |application|
        next unless scenarios_for_application?(application)
        if tagged_scenarios_for_application?(application, :production)
          application.set_status_page_status status_for_application(application, :production)
          sleep 1
        end
        if tagged_scenarios_for_application?(application, :staging)
          application.set_status_page_status status_for_application(application, :staging), environment: :staging
          sleep 1
        end
      end
    end

    def status_for_application(application, *tags)
      app_failures = failed_tagged_scenarios_for_application(application, *tags)
      if FAILURE_STATUS_TYPES.include?(app_failures.worst_failure_type)
        app_failures.worst_failure_type
      else
        SUCCESS_STATUS_TYPE
      end
    end

    def failed_tagged_scenarios_for_application(application, *tags)
      failed_scenarios.with_tags(*tags).select{|s| s.app_symbol == application.symbol }
    end

    def tagged_scenarios_for_application?(application, *tags)
      scenario_collection.with_tags(*tags).any?{|s| s.app_symbol == application.symbol }
    end

    def scenarios_for_application?(application)
      scenario_symbols.any?{|symbol| symbol == application.symbol }
    end

    private
    def failed_scenarios
      @failed_scenarios ||= scenario_collection.select(&:failed?).select(&:failure_severity)
    end

    def scenario_symbols
      @scenario_symbols ||= scenario_collection.map(&:app_symbol).uniq
    end

  end
end
