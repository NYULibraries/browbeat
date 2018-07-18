@ping @selenium
Feature: Aleph is running
  As a research scholar,
  I want to be able to see the item's holdings page
  So that I can see additional bibliographical information.

  @production @major_outage
  Scenario: Visiting Aleph on production
    Then cURL visiting Aleph should respond with success

  @staging @major_outage
  Scenario: Visiting Aleph on staging
    Then cURL visiting Aleph staging should respond with success
