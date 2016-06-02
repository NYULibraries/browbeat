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

      def previously_failing?(application)
        StatusSync.previously_failing?(application.status_page_id)
      end
    end
  end
end
