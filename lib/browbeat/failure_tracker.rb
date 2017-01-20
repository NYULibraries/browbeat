module Browbeat
  class FailureTracker

    attr_accessor :scenarios, :applications, :step_events

    def initialize
      @scenarios = ScenarioCollection.new
      @step_events = []
      @applications = ApplicationCollection.new.load_yml.load_components
    end

    def register_scenario(cucumber_scenario)
      scenarios << Scenario.new(cucumber_scenario, step_events)
      @step_events = []
    end

    def register_after_test_step(cucumber_event)
      event = StepEvent.new(cucumber_event)
      step_events << event if event.scenario_step?
    end

    def sync_status_page
      StatusSync.sync_status_page scenarios, applications
    end

    def send_status_mail
      StatusMailer.send_status scenarios, applications
    end

  end
end
