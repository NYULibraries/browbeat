Then(/^my browser should resolve to Login$/) do
  expect(page.current_path).to eql login_default_path
end

When /^I login as an NYU user$/ do
  click_link_or_button "NYU"
  expect(page).to have_content "NYU Login"
  fill_in "netid", with: login_username
  fill_in "Password", with: login_password
  click_link_or_button "Login"
end

Then /^I should be logged in$/ do
  expect(page).to have_link "Log-out"
end
