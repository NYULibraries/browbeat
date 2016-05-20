module FailureTracker
  class StatusMailer
    attr_reader :scenario_collection

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
      if ENV['FAILURE_EMAIL_RECIPIENT']
        MailxRuby.send_mail(body: body, subject: subject, to: ENV['FAILURE_EMAIL_RECIPIENT'], html: true)
      else
        puts "WARNING: No email sent since FAILURE_EMAIL_RECIPIENT is not specified"
      end
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

    private


  end
end
