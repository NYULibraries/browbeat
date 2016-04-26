After('@ping') do |scenario|
  if scenario.failed?
    # Use syntax of scenario.title to determine which
    # statuspage.io application it maps to and call
    # status = Browbeat::StatusPage::Component.new(component_id)
    # status.major_outage!
    # incident = Browbeat::StatusPage::Incident.new()
    # incident.message = "#{application_name} cannot be reached. Our administrators are looking into bringing it back up."
    # incident.status = "Investigating"
    # incident.save!
  end
end

# disable capybara overriding @selenium-tagged tests (required to run in sauce)
# with capybara; our default driver is selenium
# modified from https://github.com/saucelabs/sauce_ruby/issues/261
if ENV['DRIVER'].nil?
  Before do |scenario|
    Capybara.current_driver = :poltergeist
  end
end
