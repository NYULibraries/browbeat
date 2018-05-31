def poltergeist_driver?
  ENV['DRIVER'].nil?
end

def sauce_driver?
  ENV['DRIVER'] == 'sauce'
end

def selenium_chrome_driver?
  ENV['DRIVER'] == 'chrome'
end
