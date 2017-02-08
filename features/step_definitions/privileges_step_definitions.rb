When(/^I search privileges for "(.+)"$/) do |search_text|
  fill_in "Find your user type", with: search_text
  click_on "Search"
end

When(/^I select "(.+)" from the privileges dropdown$/) do |option_text|
  select option_text, from: privileges_dropdown
  expect(page).to have_link option_text
end

When(/^I secretly visit Privileges WebSolr$/) do
  visit privileges_web_solr_query_url
end

Then(/^my browser should resolve to (Privileges.*)$/) do |privileges_url_name|
  expect(page.current_url).to eql url_to(privileges_url_name)
end

Then(/^I should see a guide for "(.+)"$/) do |guide_text|
  expect(page).to have_text "You are a #{guide_text}"
end

Then(/^I should expect to see a privileges table$/) do
  expect(privileges_table).to be_visible
end
