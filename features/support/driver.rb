# Run specs in specific driver via DRIVER variable, e.g.:
#  DRIVER=sauce rake browbeat:check:production:all
#  DRIVER=chrome rake browbeat:check:production:all
# Runs by default in poltergist:
#  rake browbeat:check:production:all

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
      # ["Windows 7", "Internet Explorer", "9"],
      # ["Windows XP", "Internet Explorer", "7"],
      ["OS X 10.9", "safari", "7"],
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
      phantomjs: ENV['PHANTOMJS'],
      phantomjs_options: ['--load-images=no', '--ignore-ssl-errors=yes'],
      window_size: [1280, 1024],
      timeout: (ENV['TIMEOUT'] || 30).to_i,
      js_errors: false,
      phantomjs_logger: StringIO.new,
      url_blacklist: ENV['BLACKLIST_URLS']
    )
  end
end

SELENIUM_DOWNLOAD_FILETYPES = 'application/x-url' unless defined?(SELENIUM_DOWNLOAD_FILETYPES)

def configure_selenium
  Capybara.register_driver :selenium do |app|
    options = Selenium::WebDriver::Chrome::Options.new

    options.add_argument('--headless')
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-gpu')
    # options.add_argument('--disable-popup-blocking')
    options.add_argument('--window-size=1280,1024')

    options.add_preference(:download,
      directory_upgrade: true,
      prompt_for_download: false,
      default_directory: ENV['SELENIUM_DOWNLOAD_DIRECTORY'])

    # options.add_preference(:browser, set_download_behavior: { behavior: 'allow' })

    driver = Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)

    # bridge = driver.browser.send(:bridge)
    #
    # path = '/session/:session_id/chromium/send_command'
    # path[':session_id'] = bridge.session_id
    #
    # bridge.http.call(:post, path, cmd: 'Page.setDownloadBehavior',
    #                               params: {
    #                                 behavior: 'allow',
    #                                 downloadPath: ENV['SELENIUM_DOWNLOAD_DIRECTORY']
    #                           })

    driver
  end
end

# if driver set to sauce, set and configure
if sauce_driver?
  puts "Running in Sauce"
  configure_sauce
  Capybara.default_driver = :sauce
  Capybara.javascript_driver = :selenium
  Capybara.default_max_wait_time = (ENV['MAX_WAIT'] || 15).to_i
# if driver not set, default to poltergeist
elsif poltergeist_driver?
  puts "Running in Poltergeist/PhantomJS"
  configure_poltergeist
  Capybara.default_driver = :poltergeist
  Capybara.javascript_driver = :poltergeist
  Capybara.current_driver = :poltergeist
  Capybara.default_max_wait_time = (ENV['MAX_WAIT'] || 6).to_i
# otherwise, run driver as a browser via selenium
elsif selenium_chrome_driver?
  puts "Running in Selenium Chrome"
  configure_selenium
  Capybara.default_driver = :selenium
  Capybara.javascript_driver = :selenium
  Capybara.default_max_wait_time = (ENV['MAX_WAIT'] || 15).to_i
else
  raise "Unrecognized driver '#{ENV['DRIVER']}'"
end
