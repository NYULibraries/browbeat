module FailureTracker
  module Formatters
    class MailFailureFormatter
      attr_accessor :scenario_collection

      ENVIRONMENTS = %w[production staging]
      TEMPLATE = "lib/failure_tracker/templates/mail_failure.html.haml"

      def self.render(failed_scenarios)
        new(failed_scenarios).render
      end

      def initialize(failed_scenarios)
        @scenario_collection = failed_scenarios
      end

      def render
        Haml::Engine.new(File.read(TEMPLATE)).render(self)
      end

      def application_list
        Application.list_all
      end

      def environments
        ENVIRONMENTS
      end

      def failure_types
        Scenario::ORDERED_FAILURE_TYPES
      end

      # returns true if any scenarios exist for application
      def scenarios_for_application?(application)
        scenario_symbols.any?{|symbol| symbol == application.symbol }
      end

      # returns scenario collection for given application; memoized, since we have redundant calls
      def scenarios_for_application(application)
        return instance_variable_get(:"@scenarios_#{application.symbol}") if instance_variable_defined?(:"@scenarios_#{application.symbol}")
        instance_variable_set :"@scenarios_#{application.symbol}", scenario_collection.select{|s| s.app_symbol == application.symbol }
      end

      # returns true if any scenarios exist for given application and environment
      def scenarios_for_application_environment?(application, environment)
        scenarios_for_application(application).any?{|s| s.has_tag? environment }
      end

      # returns scenario collection for given application, environment, and failure type
      def scenarios_for_application_environment_failure_type(application, environment, failure_type)
        scenarios_for_application(application).with_tags(environment, failure_type)
      end

      private
      def scenario_symbols
        @scenario_symbols ||= scenario_collection.map(&:app_symbol).uniq
      end

      def get_or_set_instance_variable(instance_variable_name, &block)
        return instance_variable_get(instance_variable_name) if instance_variable_defined?(instance_variable_name)
        instance_variable_set instance_variable_name, yield
      end
    end
  end
end
