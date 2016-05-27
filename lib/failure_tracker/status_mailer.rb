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
      if any_failures? || StatusSync.previously_failing?
        send_mail
      end
    end

    def send_mail
      if ENV['FAILURE_EMAIL_RECIPIENT']
        MailxRuby.send_mail(body: body, subject: subject, to: ENV['FAILURE_EMAIL_RECIPIENT'], html: true)
      else
        puts "WARNING: No email sent since FAILURE_EMAIL_RECIPIENT is not specified"
      end
    end

    def body
      if any_failures?
        Formatters::MailFailureFormatter.render(failed_scenarios)
      else
        "Some services were previously set to failing, but Browbeat found them all operational."
      end
    end

    def subject
      if any_failures?
        "Browbeat: #{failed_scenarios.worst_failure_type.gsub('_',' ')} detected"
      else
        "Browbeat: all services now operational"
      end
    end

    def failed_scenarios
      @failed_scenarios ||= @scenario_collection.select(&:failed?)
    end

    def any_failures?
      @any_failures ||= @scenario_collection.any?(&:failed?)
    end

  end
end
