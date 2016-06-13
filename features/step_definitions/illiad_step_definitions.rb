Then /^I should see "(.+)" in the "(.+)" field$/ do |value_text, field_title|
  expect(page).to have_field(field_title, with: value_text)
end
