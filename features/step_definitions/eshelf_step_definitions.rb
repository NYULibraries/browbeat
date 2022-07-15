# need to execute script instead of using "check" due to "click intercepted" error by <div class="md-scroll-mask"">
When(/^I add the first NUI record to e-Shelf$/) do
  within nui_first_result do
    expect(page).to have_text "Add to Saved Items"
  end
  page.execute_script("document.querySelector('nyu-eshelf input').click()")
end

# need to execute script instead of using "check" due to "click intercepted" error by <div class="md-scroll-mask"">
When(/^I click e-Shelf link to open a new window$/) do
  capture_new_window do
    page.execute_script("document.querySelector('nyu-eshelf-toolbar button').click()")
  end
end

Then(/^my browser should resolve to (e-Shelf.*)$/) do |eshelf_url|
  expect(page.current_url).to eq url_to eshelf_url
end

Then(/^my browser should redirect to passive Login$/) do
  expect(page.current_url).to match url_to('login')
  expect(page.current_path).to eq passive_login_path
end

# will be replaced by NUI version
Then(/^the first record should show as "(.+)"$/) do |text|
  expect(first_result).to have_content text
end

Then(/^the first NUI record should show as "(.+)"$/) do |text|
  expect(nui_first_result).to have_content text
end
