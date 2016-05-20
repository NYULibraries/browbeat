@funcionality @selenium
Feature: e-Shelf is running
  As a NYU Libraries user,
  I want to be able to save items to my e-Shelf
  So that I can come back later and have a record of my research items.

  @production @major_outage
  Scenario: Adding a record to e-Shelf on production
    Given I visit BobCat
    When I search for "monk"
      And I add the first record to e-Shelf
      Then the first record should show as "In guest e-Shelf"
    When I click e-Shelf link
      Then I should see results matching "monk"

  @staging @major_outage
  Scenario: Adding a record to e-Shelf on staging
    Given I visit BobCat staging
    When I search for "monk"
      And I add the first record to e-Shelf
      Then the first record should show as "In guest e-Shelf"
    When I click e-Shelf link
      Then I should see results matching "monk"
