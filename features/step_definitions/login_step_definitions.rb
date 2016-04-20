Then(/^my browser should resolve to Login$/) do
  expect(page.current_path).to eql login_default_path
end

When /^I login as an NYU user$/ do
  click_link_or_button "NYU"
  # ensure we're on shibboleth login page
  expect(page).to have_content "NYU Login"
  fill_in "netid", with: shibboleth_username # can't use label; mismatch with input
  fill_in "Password", with: shibboleth_password
  click_button "Login"
end

When /^I login as an aleph staging user$/ do
  click_link_or_button "Other Borrowers"
  # ensure we're on aleph login page
  expect(page).to have_content "Login with your library card number"
  fill_in "Enter your library card number", with: aleph_staging_username
  fill_in "First four letters of your last name", with: aleph_staging_password
  click_button "Login"
end

Then /^I should be logged in$/ do
  expect(page).to have_link "Log-out"
end
