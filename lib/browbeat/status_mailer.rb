module Browbeat
  class StatusMailer
    include Helpers::ApiPageIdsHelper

    attr_reader :scenario_collection, :application_collection

    def self.send_status(scenario_collection, application_collection)
      new(scenario_collection, application_collection).send_status_if_failed
    end

    def initialize(scenario_collection, application_collection)
      @scenario_collection = scenario_collection
      @application_collection = application_collection
    end

    def send_status_if_failed
      return send_mail if send_mail?
      puts("No email sent since no #{'updated ' if recheck?}failures detected")
      return true 
    end

    def send_mail
      if !failure_email_recipient
        puts "WARNING: No email sent since FAILURE_EMAIL_RECIPIENT is not specified"
        return false 
      end
      begin
        email_metadata = {
          destination: {
            to_addresses: [
              failure_email_recipient,
            ],
          },
          message: {
            body: {
              html: {
                charset: encoding,
                data: body,
              },
            },
            subject: {
              charset: encoding,
              data: subject,
            },
          },
          source: failure_email_recipient,
        }
        resp = ses.send_email(email_metadata)
        puts "Email sent to #{failure_email_recipient}! (#{resp.message_id})\nEmail metadata:\n#{email_metadata.inspect}"
        return true
      rescue Aws::SES::Errors::ServiceError => error
        puts "Email not sent. Error message: #{error}"
        return false
      end
    end

    def body
      if any_failures?
        Presenters::MailFailurePresenter.render(failed_scenarios, scenario_applications, scenario_environments)
      else
        Presenters::MailSuccessPresenter.render(scenario_applications, scenario_environments)
      end
    end

    def subject
      if any_failures?
        "Browbeat: #{overall_worst_failure_type} detected"
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

    def all_failures?
      application_collection.any? && any_failures? && failing_scenario_application_symbols.sort == scenario_application_symbols.sort
    end

    def status_page_failures?
      scenario_environments.any? do |environment|
        components = StatusPage::API::ComponentList.new(send("status_page_#{environment}_page_id")).get
        components.any? do |comp|
          comp.failing? && send("scenario_#{environment}_component_ids").include?(comp.id)
        end
      end
    end

    def scenario_applications
      @scenario_applications ||= get_scenario_applications
    end

    def scenario_environments
      %w[production staging].select do |environment|
        scenario_collection.any? do |scenario|
          scenario.has_tag?(environment)
        end
      end
    end

    private

    def send_mail?
      return if scenario_collection.none?
      return if recheck? && all_failures?
      return if !recheck? && !any_failures? && !status_page_failures?
      true
    end

    def recheck?
      ENV['RECHECK']
    end

    def get_scenario_applications
      application_collection.select do |application|
        scenario_application_symbols.include?(application.symbol)
      end
    end

    def failing_scenario_application_symbols
      @failing_symbols ||= failed_scenarios.map(&:app_symbol).uniq
    end

    def scenario_application_symbols
      @symbols ||= @scenario_collection.map(&:app_symbol).uniq
    end

    def scenario_production_component_ids
      scenario_applications.map(&:status_page_production_id)
    end

    def scenario_staging_component_ids
      scenario_applications.map(&:status_page_staging_id)
    end

    def overall_worst_failure_type
      (failed_scenarios.with_tags(:production).worst_failure_type || 'staging outage').gsub('_',' ')
    end

    def ses
      @ses ||= Aws::SES::Client.new(region: ENV['AWS_SES_REGION'])
    end

    def encoding
      "UTF-8"
    end
    
    def failure_email_recipient
      ENV['FAILURE_EMAIL_RECIPIENT']
    end

  end
end
