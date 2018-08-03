@functionality @selenium
Feature: e-Shelf is running
  As a NYU Libraries user,
  I want to be able to save items to my e-Shelf
  So that I can come back later and have a record of my research items.

  @production @partial_outage
  Scenario: Adding a record to e-Shelf on production
    Given I visit BobCat
    When I search for "monk" in the NUI
      And I add the first NUI record to e-Shelf
      Then the first NUI record should show as "In guest e-Shelf"
    When I click on "E-SHELF" to open a new window
      Then I should see results matching "monk" in a new window

  @staging @partial_outage
  Scenario: Adding a record to e-Shelf on staging
    Given I visit BobCat staging
    When I search for "monk" in the NUI
      And I add the first NUI record to e-Shelf
      Then the first NUI record should show as "In guest e-Shelf"
    When I click on "E-SHELF" to open a new window
      Then I should see results matching "monk" in a new window
