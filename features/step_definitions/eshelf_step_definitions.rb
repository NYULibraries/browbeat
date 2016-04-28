When /^I add the first record to e-Shelf$/ do
  within first_result do
    check "Add to e-Shelf"
  end
end

When /^I click e-Shelf link$/ do
  click_link_or_button 'Guest e-shelf'
end

Then /^my browser should resolve to (e-Shelf.*)$/ do |eshelf_url|
  expect(page.current_url).to eq url_to eshelf_url
end

Then /^my browser should redirect to passive Login$/ do
  expect(page.current_url).to match url_to('login')
  expect(page.current_path).to eq passive_login_path
end

Then /^the first record should show as "(.+)"$/ do |text|
  expect(first_result).to have_content text
end
