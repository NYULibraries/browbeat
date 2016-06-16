Then /^my browser should resolve to (Arch.*)$/ do |arch_url_name|
  expect(page.current_url).to eql url_to arch_url_name
end

Then /^my browser should resolve to JSTOR$/ do
  expect(page.current_url).to eq "http://www.jstor.org/action/showBasicSearch"
end

Then /^my browser should resolve to MetaLib$/ do
  expect(page.current_url).to match /^http:\/\/metalib1.bobst.nyu.edu:8331\/V\?RN=\d+$/
end

Then /^I should see valid XML with "(.+)" node value "(.+)"$/ do |node_name, value_text|
  expect(xml_body.children).to_not be_empty
  expect(xml_body.xpath(".//#{node_name}")).to_not be_empty
  expect(xml_body.xpath(".//#{node_name}").text).to eq value_text
end
