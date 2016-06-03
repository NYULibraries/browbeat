tracker ||= Browbeat::FailureTracker.new

After do |scenario|
  tracker.register_scenario scenario
end

# disable capybara overriding @selenium-tagged tests (required to run in sauce)
# with capybara; our default driver is selenium
# modified from https://github.com/saucelabs/sauce_ruby/issues/261
if ENV['DRIVER'].nil?
  Before do |scenario|
    Capybara.current_driver = :poltergeist
  end
end

# after all, process failures
at_exit do
  puts "Syncing with StatusPage..."
  tracker.sync_status_page
  puts "Sending mail..."
  tracker.send_status_mail
  puts "Done"
end
