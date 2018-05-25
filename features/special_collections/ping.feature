@ping @selenium
Feature: Special Collections is running
  As an Archival Collections user,
  I'd like to be able to search the finding aids for a collection
  So that I know what to ask for when I visit a special collection library such as Tamiment.

  @production @major_outage
  Scenario: Visiting Special Collections on production
    Then cURL visiting Special Collections should respond with success

  @production @degraded_performance
  Scenario: Visiting Special Collections LB server 1 on production
    Then cURL insecurely visiting Special Collections LB server 1 should respond with success

  @production @degraded_performance
  Scenario: Visiting Special Collections LB server 2 on production
    Then cURL insecurely visiting Special Collections LB server 2 should respond with success

  @staging @major_outage @wip
  Scenario: Visiting Special Collections on staging
    Then cURL visiting Special Collections staging should respond with success
