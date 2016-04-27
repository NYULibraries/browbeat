Then /^my browser should resolve to (GetIt.*)$/ do |getit_name|
  expect(page.current_url).to eql url_to getit_name
end
