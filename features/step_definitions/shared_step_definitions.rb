Given(/^I visit (.+)$/) do |url_name|
  visit url_to url_name
end

Then(/^my browser should respond with a success$/) do
  expect(page.status_code).to eql 200
end
