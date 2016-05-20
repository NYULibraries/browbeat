module FailureTracker
  class StatusMailer
    attr_reader :scenario_collection

    RECIPIENT = 'eric.griffis@nyu.edu'

    def self.send_status(scenario_collection)
      new(scenario_collection).send_status_if_failed
    end

    def initialize(scenario_collection)
      @scenario_collection = scenario_collection
    end

    def send_status_if_failed
      send_mail if @scenario_collection.any?(&:failed?)
    end

    def send_mail
      MailxRuby.send_mail(body: body, subject: subject, to: RECIPIENT, html: true)
    end

    def body
      Formatters::MailFailureFormatter.render(failed_scenarios)
    end

    def subject
      "Browbeat: #{failed_scenarios.worst_failure_type.gsub('_',' ')} detected"
    end

    def failed_scenarios
      @failed_scenarios ||= @scenario_collection.select(&:failed?)
    end

  end
end
