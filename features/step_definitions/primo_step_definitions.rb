When(/^I select the first multi-version record$/) do
  first_result.find('.title a').click
end

When(/^I select "(.+)" from the "(.+)" psuedo-dropdown in the first result$/) do |option_text, select_text|
  within(first_result) do
    click_on select_text
    capture_new_window do
      click_on option_text
    end
  end
end

Then(/^my browser should resolve to BobCat$/) do
  expect(page.current_path).to eql bobcat_default_path
end

Then(/^I should see the tabbed interface$/) do
  expect(page.find('.nav-tabs')).to have_css 'li'
end

Then(/^I should see the Libraries' logo$/) do
  expect(header_background_image).to match logo_url_regex
end

Then(/^I should download an "(.+)" file$/) do |file_extension|
  expect(page.response_headers['Content-Disposition']).to match content_disposition_attachment_regex(file_extension)
end

Then(/^I should see an EasyBib record "(.+)" in a new window/) do |easybib_text|
  within_new_window do
    expect(page).to have_css('.citation', text: easybib_text)
  end
end
