module Browbeat
  module Presenters
    class MailSuccessPresenter
      attr_reader :application_list, :environments

      TEMPLATE = "lib/browbeat/templates/mail_success.html.haml"

      def self.render(scenario_applications, scenario_environments)
        new(scenario_applications, scenario_environments).render
      end

      def initialize(scenario_applications, scenario_environments)
        @application_list = scenario_applications
        @environments = scenario_environments
      end

      def render
        Haml::Engine.new(File.read(TEMPLATE)).render(self)
      end

      def failing_on_production?(application)
        application.status_page_production_component.failing? && environments.include?('production')
      end

      def failing_on_staging?(application)
        application.status_page_staging_component.failing? && environments.include?('staging')
      end
    end
  end
end
