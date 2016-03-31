if ENV['SELENIUM']
  # On demand: non-headless tests via Selenium/WebDriver
  # To run the scenarios in browser (default: Firefox), use the following command line:
  # SELENIUM=true bundle exec cucumber
  # or (to have a pause of 1 second between each step):
  # SELENIUM=true PAUSE=1 bundle exec cucumber
  Capybara.register_driver :selenium do |app|
    http_client = Selenium::WebDriver::Remote::Http::Default.new
    http_client.timeout = 120
    Capybara::Selenium::Driver.new(app, :browser => :chrome, :http_client => http_client)
  end
  Capybara.default_driver = :selenium
  AfterStep do
    sleep (ENV['PAUSE'] || 0).to_i
  end
elsif ENV['SAUCE']
  require 'sauce/cucumber'
  require 'sauce/capybara'
  Capybara.default_driver = :sauce
  # For more options see: https://github.com/saucelabs/sauce_ruby/wiki/Configuration----The-(in)Complete-Guide
  Sauce.config do |config|
    config[:browsers] = [
      ["Windows 7", "Internet Explorer", "9"],
      ["Linux", "Firefox", "19"],
      ["OSX 10.6", "Chrome", nil]
    ]
  end
else
  # DEFAULT: headless tests with poltergeist/PhantomJS
  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(
      app,
      phantomjs_options: ['--load-images=no', '--ignore-ssl-errors=yes'],
      window_size: [1280, 1024],
      timeout: 120,
      js_errors: false
    )
  end
  Capybara.default_driver    = :poltergeist
  Capybara.javascript_driver = :poltergeist
  Capybara.default_max_wait_time = 20
end
