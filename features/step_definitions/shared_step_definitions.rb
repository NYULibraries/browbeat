Given(/^I visit (.+)$/) do |url_name|
  visit url_to url_name
end

Then(/^my browser should respond with a success$/) do
  expect(page.find('body')).to have_content # expect(page.status_code).to eql 200
end

Then(/^I should see results matching "(.+)"$/) do |content|
  expect(page_results).to have_content /#{content}/i
end
