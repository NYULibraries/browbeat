Given(/^I visit (.+)$/) do |url_name|
  visit url_to url_name
end

When(/^I search for "(.*?)"$/) do |search_term|
  within('form[name=searchForm]') do
    fill_in("search_field", with: search_term)
    click_on 'Search'
  end
end

Then(/^my browser should respond with a success for (.+)$/) do |app_name|
  expect(page.find('body')).to have_content success_text_for(app_name)
end

Then(/^I should see results matching "(.+)"$/) do |content|
  expect(page_results).to have_content /#{content}/i
end
