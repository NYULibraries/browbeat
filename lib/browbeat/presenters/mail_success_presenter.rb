module Browbeat
  module Presenters
    class MailSuccessPresenter
      include Helpers::StatusPagePresenterHelper
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


    end
  end
end
