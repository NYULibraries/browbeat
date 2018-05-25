Then(/^cURL visiting (.+) should respond with success$/) do |url_name|
  expect(follow_redirect_status(url_to(url_name))).to eq "200"
end

Then(/^cURL secretly visiting (.+) should respond with success$/) do |url_name|
  raise "Cannot access #{url_name} URL while running tests in Sauce" if sauce_driver?
  expect(follow_redirect_status(url_to(url_name))).to eq "200"
end

Then(/^cURL insecurely visiting (.+) should respond with success$/) do |url_name|
  expect(follow_redirect_status(url_to(url_name), insecure: true)).to eq "200"
end

Then(/^cURL visiting (.+) should respond with (\d+)$/) do |url_name, status_code|
  expect(initial_status(url_to(url_name))).to eq status_code
end

Then(/^cURL visiting (.+) should redirect to ([^"]+)$/) do |url_name, redirect_url_name|
  redirect_locations = redirect_locations(url_to(url_name))
  expect(redirect_locations).to include url_to(redirect_url_name)
end

Then(/^cURL visiting (.+) should redirect to "(.+)"$/) do |url_name, dest_url|
  redirect_locations = redirect_locations(url_to(url_name))
  expect(redirect_locations).to include dest_url
end
