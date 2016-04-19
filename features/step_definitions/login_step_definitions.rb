Then(/^my browser should resolve to Login$/) do
  expect(page.current_path).to eql login_default_path
end
