@ping @selenium
Feature: GetIt is running
  As a catalog searcher for a known item,
  I want to be able to locate a book in the library
  So I can get it and check it out.

  @production @major_outage
  Scenario: Visiting GetIt on production
    Given I visit GetIt
    Then my browser should respond with a success for GetIt
    And my browser should resolve to GetIt

  @production @degraded_performance
  Scenario: Visiting GetIt LB server 1 on production
    Given I visit GetIt LB server 1
    And I visit GetIt LB server 1
    Then my browser should respond with a success for GetIt
    And my browser should resolve to GetIt LB server 1

  @production @degraded_performance
  Scenario: Visiting GetIt LB server 2 on production
    Given I visit GetIt LB server 2
    And I visit GetIt LB server 2
    Then my browser should respond with a success for GetIt
    And my browser should redirect to GetIt LB server 2

  @staging @major_outage
  Scenario: Visiting GetIt on staging
    Given I visit GetIt staging
    Then my browser should respond with a success for GetIt
    And my browser should resolve to GetIt staging

  @staging @major_outage
  Scenario: Visiting GetIt on staging QA
    Given I visit GetIt QA
    Then my browser should respond with a success for GetIt
    And my browser should resolve to GetIt QA
