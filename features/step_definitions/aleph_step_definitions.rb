When(/^I search by keyword for "(.+)" in "(.+)"$/) do |keywords, field_type|
  within "#keyword form" do
    fill_in "request", with: keywords
    select field_type, from: "find_code"
    click_on "Search"
  end
end

When(/^I select the first result matching "(.+)"$/) do |result_text|
  # ensure results page has loaded before clicking
  expect(page).to have_content "Results for Titles"
  within first_aleph_result_matching(result_text) do
    first('.holdinglink a').click
  end
end

Then(/^my browser should resolve to (Aleph.*)$/) do |aleph_url|
  expect(page.current_url).to match url_to(aleph_url)
  expect(page.current_path).to match /\/F\/[\d\w-]+/
end

Then(/^I should see content matching "(.+)"$/) do |text|
  expect(page).to have_content /#{text}/i
end
