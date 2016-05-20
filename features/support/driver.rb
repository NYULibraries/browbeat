# Run specs in specific driver via DRIVER variable, e.g.:
#  DRIVER=sauce rake browbeat:check:all
#  DRIVER=chrome rake browbeat:check:all
# Runs by default in poltergist:
#  rake browbeat:check:all

# configures to run in sauce, with needed requires
# modified from https://github.com/saucelabs/sauce_ruby/issues/261
def configure_sauce
  require "sauce/cucumber"

  Sauce.config do |config|
    config[:start_tunnel] = false
    config[:browsers] = [
      ["Windows 8.1", "googlechrome", "36"],
      ["Windows 8.1", "firefox", "31"],
      # ["Windows 8.1", "Internet Explorer", "11"],
      # ["Windows 8", "Internet Explorer", "10"],
      # ["Windows 7", "Internet Explorer", "9"],
      ["Windows 7", "Internet Explorer", "9"],
      # ["Windows XP", "Internet Explorer", "7"],
      # ["OS X 10.9", "safari", "7"],
      # ["OS X 10.9", "iPhone", "7.1"],
      # ["Linux", "Android", "4.4"]
    ]
    config[:name] = "#{`basename $(git rev-parse --show-toplevel)`}"
    config[:build] = "#{`git rev-parse --short HEAD`}"
    config[:tags] = [ ENV['CI'] ? "CI" : `whoami`, "#{`git rev-parse --abbrev-ref HEAD`}" ]
    config[:username] = ENV['SAUCE_USERNAME'] || raise("Set SAUCE_USERNAME and SAUCE_ACCESS_KEY to run on sauce")
    config[:access_key] = ENV['SAUCE_ACCESS_KEY'] || raise("Set SAUCE_USERNAME and SAUCE_ACCESS_KEY to run on sauce")
    config['screen-resolution'] = "1280x1024"
  end
end

# configure poltergeist with js error throwing/logging off and with timeouts
# set for our tests
def configure_poltergeist
  # DEFAULT: headless tests with poltergeist/PhantomJS
  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(
      app,
      phantomjs_options: ['--load-images=no', '--ignore-ssl-errors=yes'],
      window_size: [1280, 1024],
      timeout: (ENV['TIMEOUT'] || 30).to_i,
      js_errors: false,
      phantomjs_logger: StringIO.new
    )
  end
end

# if driver set to sauce, set and configure
case ENV['DRIVER']
when 'sauce'
  configure_sauce
  Capybara.default_driver = :sauce
  Capybara.javascript_driver = :selenium
  Capybara.default_max_wait_time = ENV['MAX_WAIT'] || 5
# if driver not set, default to poltergeist
when nil
  configure_poltergeist
  Capybara.default_driver = :poltergeist
  Capybara.javascript_driver = :poltergeist
  Capybara.current_driver = :poltergeist
  Capybara.default_max_wait_time = ENV['MAX_WAIT'] || 5
# otherwise, run driver as a browser via selenium
else
  Capybara.register_driver :selenium do |app|
    Capybara::Selenium::Driver.new(app, browser: ENV['DRIVER'].to_sym)
  end
  Capybara.default_driver = :selenium
  Capybara.javascript_driver = :selenium
  Capybara.default_max_wait_time = ENV['MAX_WAIT'] || 15
end
