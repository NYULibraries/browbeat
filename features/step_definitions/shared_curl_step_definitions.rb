Then(/^cURL visiting (.+) should respond with success$/) do |url_name|
  final_response_headers = curl_headers(url_to(url_name)).last
  expect(final_response_headers).to include get_status(200)
end

Then(/^cURL insecurely visiting (.+) should respond with success$/) do |url_name|
  final_response_headers = curl_headers(url_to(url_name), insecure: true).last
  expect(final_response_headers).to include get_status(200)
end

Then(/^cURL visiting (.+) should respond with (\d+)$/) do |url_name, status_code|
  initial_response_headers = curl_headers(url_to(url_name)).first
  expect(initial_response_headers).to include get_status(status_code)
end

Then(/^cURL visiting (.+) should redirect to ([^"]+)$/) do |url_name, redirect_url_name|
  redirect_locations = redirect_locations(url_to(url_name))
  expect(redirect_locations).to include url_to(redirect_url_name)
end

Then(/^cURL visiting (.+) should redirect to "(.+)"$/) do |url_name, dest_url|
  redirect_locations = redirect_locations(url_to(url_name))
  expect(redirect_locations).to include dest_url
end
