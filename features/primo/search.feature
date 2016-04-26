@functionality @selenium
Feature: Primo is running
  As a BobCat user
  In order to know whether or not I can do my research today
  I want to be informed about the application's status.

  @production @major_outage
  Scenario: Searching on production
    Given I visit BobCat
    When I search for "catcher in the rye"
    Then I should see results matching "catcher in the rye"

  @staging @major_outage
  Scenario: Searching on staging
    Given I visit BobCat staging
    When I search for "catcher in the rye"
    Then I should see results matching "catcher in the rye"
