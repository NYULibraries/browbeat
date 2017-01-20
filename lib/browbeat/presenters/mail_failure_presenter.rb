module Browbeat
  module Presenters
    class MailFailurePresenter
      include Helpers::ScrubFigsHelper
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

      def ordered_application_list
        @application_list.sort_by{|app| application_severity_map[app.symbol] }
      end

      # returns true if any scenarios exist for application
      def scenarios_for_application?(application)
        scenario_symbols.any?{|symbol| symbol == application.symbol }
      end

      def worst_application_failure(application)
        col = scenarios_for_application(application)
        col.worst_failure_type&.tr('_', ' ')
      end

      # returns scenario collection for given application; memoized, since we have redundant calls
      def scenarios_for_application(application)
        app_symbol_grouped_scenarios[application.symbol] || ScenarioCollection.new
      end

      def scenarios_for_application_failure_type(application, failure_type)
        x = scenarios_for_application(application)
        x.with_tags(failure_type)
      end

      def standardize_line(line)
        line_match_data(line).to_s
      end

      def file_link(line)
        "https://github.com/NYULibraries/browbeat/blob/master/#{line_match_data(line).captures.join('#L')}"
      end

      private
      def app_symbol_grouped_scenarios
        @app_symbol_grouped_scenarios ||= scenario_collection.group_by(&:app_symbol)
      end

      def application_severity_map
        @application_severity_map ||= app_symbol_grouped_scenarios.map do |app_symbol, app_scenarios|
          [app_symbol, app_scenarios.map(&:failure_severity).compact.min]
        end.to_h
      end

      def scenario_symbols
        app_symbol_grouped_scenarios.keys
      end

      def line_match_data(line)
        line.match(/(?<filepath>features\/.+):(?<line_num>\d+).+\z/) || raise("Could not match line: '#{line}'")
      end
    end
  end
end
