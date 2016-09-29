module Browbeat
  module Presenters
    class MailFailurePresenter
      attr_accessor :scenario_collection, :application_list, :environments

      TEMPLATE = "lib/browbeat/templates/mail_failure.html.haml"

      def self.render(failed_scenarios, scenario_applications, scenario_environments)
        new(failed_scenarios, scenario_applications, scenario_environments).render
      end

      def initialize(failed_scenarios, scenario_applications, scenario_environments)
        @scenario_collection = failed_scenarios
        @application_list = scenario_applications
        @environments = scenario_environments
      end

      def render
        Haml::Engine.new(File.read(TEMPLATE)).render(self)
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

      def screenshots_url
        "https://github.com/NYULibraries/browbeat-screenshots/tree/#{jenkins_build_tag.tr(' ','_')}" if jenkins_build_tag
      end

      def jenkins_env?
        !!jenkins_build_tag
      end
      
      def jenkins_build_tag
        ENV['BUILD_TAG']
      end

      private

      def scenario_symbols
        @scenario_symbols ||= scenario_collection.map(&:app_symbol).uniq
      end
    end
  end
end
