Then /^my browser should resolve to (Website.*)$/ do |website_url_name|
  expect(page.current_url).to eql url_to(website_url_name)
end
