Then(/^my browser should resolve to Login$/) do
  expect(page.current_path).to eql login_default_path
end

When /^I login as an NYU user$/ do
  step "I login as NYU user \"#{shibboleth_username}\" with password \"#{shibboleth_password}\""
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

Then /^I should see valid XML without "(.+)" node$/ do |node_name|
  expect(xml_body.xpath('.//bor-info')).to_not be_empty
  expect(xml_body.xpath(".//#{node_name}")).to be_empty
end

Then(/^my browser should redirect to (Login.*)$/) do |login_url_name|
  expect(page.current_path).to eql login_default_path
  # test full URL
  expect(page.current_url).to eql url_to(login_url_name) + login_default_path
end
