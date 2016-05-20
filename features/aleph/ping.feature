@ping @selenium
Feature: Aleph is running
  As a research scholar,
  I want to be able to see the item's holdings page
  So that I can see additional bibliographical information.

  @production @major_outage
  Scenario: Visiting Aleph on production
    Given I visit Aleph
    Then my browser should respond with a success for Aleph
    And my browser should resolve to Aleph

  @staging @major_outage
  Scenario: Visiting Aleph on staging
    Given I visit Aleph staging
    Then my browser should respond with a success for Aleph
    And my browser should resolve to Aleph staging
