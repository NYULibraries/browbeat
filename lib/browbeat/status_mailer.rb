module Browbeat
  class StatusMailer
    attr_reader :scenario_collection

    def self.send_status(scenario_collection)
      new(scenario_collection).send_status_if_failed
    end

    def initialize(scenario_collection)
      @scenario_collection = scenario_collection
    end

    def send_status_if_failed
      if any_failures? || previous_failures?
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
        Presenters::MailFailurePresenter.render(failed_scenarios, scenario_applications)
      else
        Presenters::MailSuccessPresenter.render(scenario_applications)
      end
    end

    def subject
      if any_failures?
        "Browbeat: #{failed_scenarios.worst_failure_type.gsub('_',' ')} detected"
      else
        "Browbeat: services now operational"
      end
    end

    def failed_scenarios
      @failed_scenarios ||= @scenario_collection.select(&:failed?)
    end

    def any_failures?
      @any_failures ||= @scenario_collection.any?(&:failed?)
    end

    def scenario_applications
      @scenario_applications ||= get_scenario_applications
    end

    private

    def get_scenario_applications
      Application.list_all.select do |application|
        scenario_application_symbols.include?(application.symbol)
      end
    end

    def scenario_application_symbols
      @symbols ||= @scenario_collection.map(&:app_symbol)
    end

    def previous_failures?
      StatusSync.previously_failing?(scenario_applications.map(&:status_page_id))
    end

  end
end
