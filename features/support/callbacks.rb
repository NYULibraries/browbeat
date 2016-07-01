def poltergeist_driver?
  ENV['DRIVER'].nil?
end

# disable capybara overriding @selenium-tagged tests (required to run in sauce)
# with capybara; our default driver is selenium
# modified from https://github.com/saucelabs/sauce_ruby/issues/261
if poltergeist_driver?
  Before do |scenario|
    Capybara.current_driver = :poltergeist
  end
end

# clear downloads after each test
if !poltergeist_driver?
  After do |scenario|
    FileUtils.rm_f(ENV['SELENIUM_DOWNLOAD_DIRECTORY'])
  end
end

if ENV['DRIVER'] == 'sauce'
  Before do |scenario|
    if scenario.source_tag_names.include?("@no_sauce")
      scenario.skip_invoke!
    end
  end
end

unless %w[false off].include?(ENV["FAILURE_TRACKER"])
  tracker ||= Browbeat::FailureTracker.new

  After do |scenario|
    tracker.register_scenario scenario
  end

  # after all, process failures
  at_exit do
    puts "Syncing with StatusPage..."
    tracker.sync_status_page
    puts "Sending mail..."
    tracker.send_status_mail
    puts "Done"
  end
end
