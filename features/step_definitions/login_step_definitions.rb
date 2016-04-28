Then(/^my browser should resolve to Login$/) do
  expect(page.current_path).to eql login_default_path
end

When /^I login as an NYU user$/ do
  pending # step "I login as NYU user \"#{shibboleth_username}\" with password \"#{shibboleth_password}\""
end

When /^I login as an NYU staging user$/ do
  step "I login as NYU user \"#{shibboleth_staging_username}\" with password \"#{shibboleth_staging_password}\""
end

When /^I login as NYU user "(.+)" with password "(.+)"/ do |username, password|
  click_link_or_button "NYU"
  # ensure we're on shibboleth login page
  expect(page).to have_content "NYU Login"
  fill_in "netid", with: username
  fill_in "Password", with: password
  click_button "Login"
end

Then /^I should be logged in$/ do
  expect(page).to have_link "Log-out"
end
