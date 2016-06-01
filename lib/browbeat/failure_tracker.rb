module Browbeat
  class FailureTracker

    attr_accessor :scenarios

    def initialize
      @scenarios = ScenarioCollection.new
    end

    def register_scenario(scenario)
      scenarios << Scenario.new(scenario)
    end

    def sync_status_page
      StatusSync.sync_status_page scenarios
    end

    def send_status_mail
      StatusMailer.send_status scenarios
    end

  end
end
