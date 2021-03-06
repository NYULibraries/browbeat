When(/^I search for "(.+)" journal title$/) do |text|
  fill_in('journal_title', with: text)
  within('#primary-search') do
    click_on "Search"
  end
end

When(/^I select the first "(.+)" record$/) do |type|
  capture_new_window do
    first_result_matching(type).find('.title a').click
  end
end

Then(/^my browser should resolve to (GetIt.*)$/) do |getit_url_name|
  expect(page.current_url).to eql url_to getit_url_name
end

Then(/^my browser should open a (GetIt.*) page in a new window$/) do |getit_url_name|
  within_new_window do
    expect(page).to have_content "Back to results"
    expect(page.current_url).to match url_to(getit_url_name)
  end
end

Then(/^I should see results under "(.+)" section$/) do |section_title|
  expect(page).to have_content section_title
  expect(page).to have_text "NYU access only"
  expect(first_umlaut_section_matching(section_title)).to have_text "NYU access only"
end

Then(/^I should see results under "(.+)" section in a new window$/) do |section_title|
  within_new_window do
    expect(page).to have_content section_title
    expect(page).to have_css '.umlaut-section'
    expect(first_umlaut_section_matching(section_title)).to have_css '.umlaut_section_content'
    expect(first_umlaut_section_matching(section_title).first('.umlaut_section_content')).to have_content
  end
end
