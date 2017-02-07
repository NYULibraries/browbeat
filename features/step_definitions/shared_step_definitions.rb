Given(/^I visit (.+)$/) do |url_name|
  visit url_to url_name
end

Given(/^I login as an NYU user$/) do
  steps %Q{
    Given I visit Login
    When I click on "NYU"
    And I enter NYU credentials
    And I click "Continue" if prompted
  }
end

Given(/^I login as an NYU user if prompted$/) do
  if page.has_text? "Select your affiliation to login"
    steps %Q{
      When I click on "NYU"
      And I enter NYU credentials
      And I click "Continue" if prompted
    }
  end
end

Given(/^I login as an NYU staging user$/) do
  steps %Q{
    Given I visit Login staging
    When I click on "NYU"
    And I enter NYU staging credentials
    And I click "Continue" if prompted
  }
end

Given(/^I login as an NYU staging user if prompted$/) do
  if page.has_text? "Select your affiliation to login"
    steps %Q{
      When I click on "NYU"
      And I enter NYU staging credentials
      And I click "Continue" if prompted
    }
  end
end

When(/^I click on "(.+)"$/) do |link_name|
  expect(page).to have_text link_name
  click_on link_name
end

When(/^I search for "(.*?)"$/) do |search_term|
  within('form[name=searchForm]') do
    fill_in("search_field", with: search_term)
    click_on 'Search'
  end
end

Then(/^my browser should respond with a? ?success for (.+)$/) do |app_name|
  expect(page).to have_text success_text_for(app_name)
end

Then(/^I should see results matching "(.+)"$/) do |content|
  expect(page_results).to have_content /#{content}/i
end
