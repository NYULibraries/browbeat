Given(/^I visit "(.*?)"$/) do |url|
  visit url
end

Then(/^my browser should resolve to BobCat$/) do
  expect(page.current_path).to eql bobcat_default_path
end

Then(/^my browser should respond with a success$/) do
  expect(page.status_code).to eql 200
end

When(/^I search for "(.*?)"$/) do |search_term|
  within('form[name=searchForm]') do
    fill_in("search_field", :with => search_term)
    click_on 'Search'
  end
end

Then(/^I should see results$/) do
  expect(page.find('.results')).to have_content
end
