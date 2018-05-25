@ping @selenium
Feature: GetIt is running
  As a catalog searcher for a known item,
  I want to be able to locate a book in the library
  So I can get it and check it out.

  @production @major_outage
  Scenario: Visiting GetIt on production
    Then cURL visiting GetIt should respond with success

  @production @degraded_performance
  Scenario: Visiting GetIt LB server 1 on production
    Then cURL visiting GetIt LB server 1 should redirect to GetIt LB server 1 secure

  @production @degraded_performance
  Scenario: Visiting GetIt LB server 2 on production
    Then cURL visiting GetIt LB server 2 should redirect to GetIt LB server 2 secure

  @staging @major_outage
  Scenario: Visiting GetIt on staging
    Then cURL visiting GetIt staging should respond with success

  @staging @major_outage
  Scenario: Visiting GetIt on staging QA
    Then cURL visiting GetIt QA should respond with success
