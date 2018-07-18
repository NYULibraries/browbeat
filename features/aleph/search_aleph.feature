@functionality @selenium
Feature: Aleph is running
  As a research scholar,
  I want to be able to see the item's holdings page
  So that I can see additional bibliographical information.

  @production @major_outage
  Scenario: Searching on production
    Given I visit Aleph
    When I search by keyword for "The American Journal of Nursing" in "Title"
    And I select the first result matching "The American Journal of Nursing"
    Then I should see content matching "NYU Public Catalog - Holdings"
    And I should see content matching "The American Journal of Nursing"

  @staging @major_outage
  Scenario: Searching on staging
    Given I visit Aleph staging
    When I search by keyword for "The American Journal of Nursing" in "Title"
    And I select the first result matching "The American Journal of Nursing"
    Then I should see content matching "NYU Public Catalog - Holdings"
    And I should see content matching "The American Journal of Nursing"
