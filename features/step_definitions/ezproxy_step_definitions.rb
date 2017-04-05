Then(/^my browser should resolve to (EZProxy.*)$/) do |ezproxy_url_name|
  expect(page.current_url).to eq combine_url(url_to(ezproxy_url_name), ezproxy_default_path)
end

Then(/^I should see a JSTOR page/) do
  expect(page).to have_text "Access Check"
end

Then(/^I should see a link with href containing "(.+)"$/) do |href_text|
  expect(page).to have_content
  expect(page).to have_xpath "//a[contains(@href,'#{href_text}')]"
end
