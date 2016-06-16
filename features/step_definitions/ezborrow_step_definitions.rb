When /^I search EZBorrow for "(.+)"$/ do |search_text|
  fill_in "query", with: search_text
  click_on "Search"
end

Then /^my browser should resolve to EZBorrow$/ do
  expect(page.current_url).to eq "https://e-zborrow.relaisd2d.com/index.html"
end

Then /^I should see EZBorrow results$/ do
  expect(page).to have_content "Showing"
  expect(ezborrow_results).to have_content
end
