Then(/^my browser should redirect to (Login.*)$/) do |login_url_name|
  expect(page.current_path).to eql login_default_path
  # test full URL
  expect(page.current_url).to eql url_to(login_url_name) + login_default_path
end
