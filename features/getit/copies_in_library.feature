@ping @selenium
Feature: Aleph is running
  As a research scholar,
  I want to be able to see the item's holdings page
  So that I can see additional bibliographical information.

  @production @degraded_service
  Scenario: Searching on production
    Given I visit BobCat
    When I search for "The green grass tango"
    And I select the first "Book" record
    Then I should see results under "Copies in Library" section in a new window

  @staging @degraded_service 
  Scenario: Searching on staging
    Given I visit BobCat staging
    When I search for "The green grass tango"
    And I select the first "Book" record
    Then I should see results under "Copies in Library" section in a new window
