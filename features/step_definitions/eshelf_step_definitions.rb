Then /^my browser should resolve to (E-shelf.*)$/ do |eshelf_url|
  expect(page.current_url).to eq url_to eshelf_url
end

Then /^my browser should redirect to passive Login$/ do
  expect(page.current_url).to match url_to('login')
  expect(page.current_path).to eq passive_login_path
end
