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

      def failing_on_status_page?(application)
        failing_on_production?(application) || failing_on_staging?(application)
      end

      def failing_on_production?(application)
        environments.include?('production') && application.status_page_production_component.failing?
      end

      def failing_on_staging?(application)
        environments.include?('staging') && application.status_page_staging_component.failing?
      end
    end
  end
end
