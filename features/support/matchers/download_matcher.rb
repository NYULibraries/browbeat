# Usage:
#  expect(page).to download_file "some_file.pdf"
#  expect(page).to download_file /.+\.pdf/

def get_download_filename(page)
  if Capybara.current_driver == :poltergeist
    return unless page.respond_to?(:response_headers) && page.response_headers['Content-Disposition']
    match_data = page.response_headers['Content-Disposition'].match(/^attachment; filename="(.+)"$/)
    match_data ? match_data[1] : match_data
  else
    Dir[File.join(FileUtils.pwd, ENV['SELENIUM_DOWNLOAD_DIRECTORY'], '*')].last
  end
end

RSpec::Matchers.define :download_file do |expected_filename|
  match do |page|
    return false unless actual_filename = get_download_filename(page)
    if expected_filename.is_a?(Regexp)
      actual_filename.match(expected_filename)
    else
      actual_filename == expected_filename
    end
  end

  failure_message_for_should do |page|
    if actual_filename = get_download_filename(page)
      "expected that downloaded file #{actual_filename.inspect} would match #{expected_filename.inspect}"
    elsif page.is_a?(Capybara::Session)
      "expected that page would download a file"
    else
      "expected #{page} to be a Capybara page (Capybara::Session)"
    end
  end

  failure_message_for_should_not do |page|
    if actual_filename = get_download_filename(page)
      "expected that downloaded file #{actual_filename.inspect} would not match #{expected_filename.inspect}"
    elsif page.is_a?(Capybara::Session)
      "expected that page would download a file"
    else
      "expected #{page} to be a Capybara page (Capybara::Session)"
    end
  end
end
