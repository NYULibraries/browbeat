# will be replaced by NUI version
When(/^I add the first record to e-Shelf$/) do
  within first_result do
    check "Add to e-Shelf"
  end
end

When(/^I add the first NUI record to e-Shelf$/) do
  #page.execute_script("document.querySelector('.md-scroll-mask').remove()")
  within nui_first_result do
    expect(page).to have_text "Add to e-Shelf"
  end
  page.execute_script("document.querySelector('nyu-eshelf input').click()")
  #within nui_first_result do
  #  check "Add to e-Shelf"
  #end
end

When(/^I click e-Shelf link to open a new window$/) do
  #click_link_or_button 'Guest e-shelf'
  capture_new_window do
        page.execute_script("document.querySelector('nyu-eshelf-toolbar button').click()")

    #find(:link_or_button, text: , match: :first).click
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
