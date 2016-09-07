When(/^I search for "(.+)" in Special Collections$/) do |search_term|
  within('.search form') do
    fill_in("q", with: search_term)
    click_on 'Search'
  end
end

When(/^I click on external link "(.+)"$/) do |link_name|
  capture_new_window do
    click_on link_name
  end
end

When(/^I secretly visit Special Collections WebSolr$/) do
  visit special_collections_web_solr_url
end

Then(/^my browser should resolve to (Special Collections.*)$/) do |special_collections_url_name|
  expect(page.current_path).to eql special_collections_default_path
  expect(page.current_url).to eql combine_url(url_to(special_collections_url_name), special_collections_default_path)
end

Then(/^my browser should redirect to Login authorization page$/) do
  expect(page.current_url).to match passive_login_url_regex
end

Then(/^my browser should open a new window with finding aid base URL$/) do
  within_new_window do
    expect(page.current_url).to match finding_aid_base_url
  end
end

Then(/^I should see Special Collections results$/) do
  expect(page).to have_css '.document'
end
