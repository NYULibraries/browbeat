When /^I click on "(.+)"$/ do |link_name|
  click_on link_name
end

Then /^my browser should resolve to (Arch.*)$/ do |arch_url_name|
  expect(page.current_url).to eql url_to arch_url_name
end

Then /^my browser should resolve to JSTOR$/ do
  expect(page.current_url).to eq "http://www.jstor.org/action/showBasicSearch"
end
