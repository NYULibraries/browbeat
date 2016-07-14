module Browbeat
  class FailureTracker

    attr_accessor :scenarios, :applications

    def initialize
      @scenarios = ScenarioCollection.new
      @applications = ApplicationCollection.new.load_yml.load_components
    end

    def register_scenario(scenario)
      scenarios << Scenario.new(scenario)
    end

    def sync_status_page
      StatusSync.sync_status_page scenarios, applications
    end

    def send_status_mail
      StatusMailer.send_status scenarios, applications
    end

  end
end
