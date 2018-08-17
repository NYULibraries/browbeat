@functionality @selenium
Feature: Aleph is running
  As a research scholar,
  I want to be able to see the item's holdings page
  So that I can see additional bibliographical information.

  @production @partial_outage @wip
  Scenario: Searching on production
    Given I visit BobCat
    When I search for "The green grass tango" in the NUI
    And I select the first NUI record
    And I click on "Check Availability" to open a new window
    Then I should see results under "Copies in Library" section in a new window

  @staging @partial_outage @wip
  Scenario: Searching on staging
    Given I visit BobCat staging
    When I search for "The green grass tango" in the NUI
    And I select the first NUI record
    And I click on "Check Availability" to open a new window
    Then I should see results under "Copies in Library" section in a new window
