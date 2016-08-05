Given(/^I login as an Aleph user$/) do
  click_on "Other Borrowers"
  fill_in "Enter your library card number", with: aleph_username
  fill_in "First four letters of your last name", with: aleph_username
  click_button "Login"
end

Then(/^my browser should resolve to (MaRLi.*)$/) do |marli_url_name|
  expect(page.current_url).to match url_to(marli_url_name)
end
