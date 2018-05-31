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

# using sauce driver, skip tests that output sensitive login info
if sauce_driver?
  Before do |scenario|
    if scenario.source_tag_names.include?("@no_sauce")
      scenario.skip_invoke!
    end
  end
end

# allow separate max wait time for scenarios requiring login
if ENV['LOGIN_MAX_WAIT']
  Around('@login_required') do |scenario, block|
    Capybara.using_wait_time(ENV['LOGIN_MAX_WAIT'].to_i) do
      block.call
    end
  end
end

if selenium_chrome_driver?
  After('@login_required') do |scenario|
    puts "Quit selenium"
    # Capybara.reset_sessions!
    # page.driver.browser.close
    Capybara.current_session.driver.quit
    # configure_selenium
    # Capybara.default_driver = :selenium
    # Capybara.javascript_driver = :selenium
    # Capybara.current_driver = :selenium
  end
end

# configure failure tracker emails and status page sync unless specified
unless %w[false off].include?(ENV["FAILURE_TRACKER"])
  tracker ||= Browbeat::FailureTracker.new

  # register each scenario
  After do |scenario|
    tracker.register_scenario scenario
  end

  # register each step event
  AfterConfiguration do |config|
    config.on_event :after_test_step do |event|
      tracker.register_after_test_step event
    end
  end

  # after all, process failures
  at_exit do
    puts "Sending mail..."
    tracker.send_status_mail
    puts "Syncing with StatusPage..."
    tracker.sync_status_page
    puts "Done"
  end
end

# automatically screenshots failures if specified
if ENV['SCREENSHOT_FAILURES']
  require 'capybara-screenshot/cucumber'

  # remove previous screenshots if any
  FileUtils.rm Dir.glob("screenshot_*")

  # customize filenames to include dasherized scenario name, e.g.:
  #  screenshot_exporting-citations-on-production_****.png
  Capybara::Screenshot.register_filename_prefix_formatter(:cucumber) do |cucumber_scenario|
    Browbeat::Scenario.new(cucumber_scenario).screenshot_filename_prefix
  end

  # upload screenshots to S3
  Capybara::Screenshot.s3_configuration = {
    s3_client_credentials: {
      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
      region: "us-east-1",
    },
    bucket_name: ENV['AWS_S3_BUCKET_NAME'],
    key_prefix: Browbeat::AWS::S3::ScreenshotManager.key_prefix
  }
end
