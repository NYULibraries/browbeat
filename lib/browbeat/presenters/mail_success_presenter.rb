module Browbeat
  module Presenters
    class MailSuccessPresenter
      attr_reader :application_list

      TEMPLATE = "lib/browbeat/templates/mail_success.html.haml"

      def self.render(scenario_applications)
        new(scenario_applications).render
      end

      def initialize(scenario_applications)
        @application_list = scenario_applications
      end

      def render
        Haml::Engine.new(File.read(TEMPLATE)).render(self)
      end

      def failing_on_production?(application)
        application.status_page_production_component.failing?
      end

      def failing_on_staging?(application)
        application.status_page_staging_component.failing?
      end
    end
  end
end
