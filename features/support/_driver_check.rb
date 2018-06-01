def poltergeist_driver?
  ENV['DRIVER'] == 'poltergeist' || ENV['DRIVER'] == 'phantomjs'
end

def sauce_driver?
  ENV['DRIVER'] == 'sauce'
end

def selenium_chrome_driver?
  ENV['DRIVER'].nil? || ENV['DRIVER'] == 'chrome'
end
