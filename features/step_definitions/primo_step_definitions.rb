Then(/^my browser should resolve to BobCat$/) do
  expect(page.current_path).to eql bobcat_default_path
end

When(/^I search for "(.*?)"$/) do |search_term|
  within('form[name=searchForm]') do
    fill_in("search_field", :with => search_term)
    click_on 'Search'
  end
end

Then(/^I should see the tabbed interface$/) do
  expect(page.find('.nav-tabs')).to have_css 'li'
end

Then(/^I should see the Libraries' logo$/) do
  expect(header_background_image).to match logo_url_regex
end
