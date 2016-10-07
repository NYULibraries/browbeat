@functionality @selenium
Feature: GetIt is running
  As a catalog searcher for a known item,
  I want to be able to locate a book in the library
  So I can get it and check it out.

  @production @partial_outage
  Scenario: Searching for Online Access
    Given I visit BobCat
    When I search for "the new yorker"
    And I select the first "Electronic Journal" record
    Then my browser should open a GetIt page in a new window
    And I should see results under "Online Access" section in a new window

  @staging @partial_outage
  Scenario: Searching for Online Access on staging
    Given I visit BobCat staging
    When I search for "the new yorker"
    And I select the first "Electronic Journal" record
    Then my browser should open a GetIt QA page in a new window
    And I should see results under "Online Access" section in a new window
