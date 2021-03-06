When(/^I search EZBorrow for "(.+)"$/) do |search_text|
  expect(page).to have_content "Copyright"
  fill_in "query", with: search_text
  click_on "Search"
end

Then(/^my browser should resolve to EZBorrow$/) do
  expect(page.current_url).to eq "https://e-zborrow.relaisd2d.com/index.html"
end

Then(/^I should see EZBorrow results page$/) do
  expect(page).to have_content "Sort by"
  # expect(ezborrow_results).to have_content
end
