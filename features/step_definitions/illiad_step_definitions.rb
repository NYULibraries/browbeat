Then(/^cURL visiting (.+) should redirect to (.+)$/) do |url_name, redirect_url_name|
  headers = curl_result(url_to(url_name))
  expect(headers).to include "302 Redirection"
  expect(headers).to include "Location: #{url_to(redirect_url_name)}"
end

# Then(/^I should see "(.+)" in the "(.+)" field$/) do |value_text, field_title|
#   expect(page).to have_field(field_title, with: value_text)
# end
