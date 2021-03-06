Then(/^my browser should resolve to (Login.*)$/) do |login_url_name|
  expect(page.current_path).to eql login_default_path
  expect(page.current_url).to eql combine_url(url_to(login_url_name), login_default_path)
end

When(/^I click on NYU Shibboleth link$/) do
  find('#nyu_shibboleth-login').click
end

When(/^I enter NYU credentials$/) do
  expect(page).to have_content "NYU Login"
  step "I enter username \"#{shibboleth_username}\" with password \"#{shibboleth_password}\""
end

When(/^I enter NYU staging credentials$/) do
  expect(page).to have_content "NYU Login"
  step "I enter username \"#{shibboleth_staging_username}\" with password \"#{shibboleth_staging_password}\""
end

When(/^I enter username "(.+)" with password "(.+)"$/) do |username, password|
  fill_in "NetID", with: username
  fill_in "Password", with: password
  click_button "LOG IN"
end

When(/^I click "(.+)" if prompted$/) do |button_text|
  if page.has_button?(button_text) #|| page.has_link?(button_text)
    click_on button_text
  end
end

Then(/^I should be logged in$/) do
  expect(page).to have_link "Log-out"
end

Then(/^I should be logged in on BobCat NUI$/) do
  expect(page).to have_css "button[aria-label=\"Click to sign out, change language and access library card\"]"
end

Then(/^I should see valid XML without "(.+)" node$/) do |node_name|
  expect(xml_body.children).to_not be_empty
  expect(xml_body.xpath(".//bor-info")).to_not be_empty
  expect(xml_body.xpath(".//#{node_name}")).to be_empty
end
