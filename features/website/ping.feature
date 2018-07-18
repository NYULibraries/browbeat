@ping @selenium
Feature: Website is running
  As a Bobst user,
  I want to be able to search the Library catalog from the website homepage.

  @major_outage @production
  Scenario: Visiting Website on production
    Then cURL visiting Website should respond with success

  @major_outage @staging
  Scenario: Visiting Website on staging
    Then cURL visiting Website staging should respond with success
