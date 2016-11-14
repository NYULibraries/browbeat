@functionality @selenium
Feature: GetIt is running
  As a catalog searcher for a known item,
  I want to be able to locate a book in the library
  So I can get it and check it out.

  @production @partial_outage
  Scenario: Searching for Online Access
    Given I visit GetIt
    When I search for "the new yorker" journal title
    And I select the first "Journal" record
    Then I should see results under "Online Access" section in a new window

  @staging @partial_outage
  Scenario: Searching for Online Access on staging
    Given I visit GetIt staging
    When I search for "the new yorker" journal title
    And I select the first "Journal" record
    Then I should see results under "Online Access" section in a new window

  @staging @partial_outage
  Scenario: Searching for Online Access on staging QA
    Given I visit GetIt QA
    When I search for "the new yorker" journal title
    And I select the first "Journal" record
    Then I should see results under "Online Access" section in a new window
