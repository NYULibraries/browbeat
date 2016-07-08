module Browbeat
  class StatusSync
    extend Browbeat::Helpers::ApiPageIdsHelper

    attr_accessor :scenario_collection

    SUCCESS_STATUS_TYPE = 'operational'
    FAILURE_STATUS_TYPES = %w[major_outage partial_outage degraded_performance]

    def self.sync_status_page(scenario_collection)
      @previously_failing_components = get_failing_components
      @previously_failing_staging_components = get_failing_staging_components
      new(scenario_collection).sync_status_page
    end

    def self.previously_failing?(*component_ids)
      component_ids.flatten.any? do |component_id|
        @previously_failing_components.map(&:id).include?(component_id)
      end
    end

    def self.previously_failing_on_staging?(*component_ids)
      component_ids.flatten.any? do |component_id|
        @previously_failing_staging_components.map(&:id).include?(component_id)
      end
    end

    def self.get_failing_components
      component_list = StatusPage::API::ComponentList.new(status_page_production_page_id)
      component_list.get.to_a.select(&:failing?)
    end

    def self.get_failing_staging_components
      staging_component_list = StatusPage::API::ComponentList.new(status_page_staging_page_id)
      staging_component_list.get.to_a.select(&:failing?)
    end

    def initialize(scenario_collection)
      @scenario_collection = scenario_collection
    end

    def sync_status_page
      application_list.each do |application|
        next unless scenarios_for_application?(application)
        if tagged_scenarios_for_application?(application, :production)
          application.set_status_page_status status_for_application(application, :production)
        end
        if tagged_scenarios_for_application?(application, :staging)
          application.set_status_page_status status_for_application(application, :staging), environment: :staging
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
    def application_list
      @application_list ||= ApplicationCollection.new.load_yml
    end

    def failed_scenarios
      @failed_scenarios ||= scenario_collection.select(&:failed?).select(&:failure_severity)
    end

    def scenario_symbols
      @scenario_symbols ||= scenario_collection.map(&:app_symbol).uniq
    end

  end
end
