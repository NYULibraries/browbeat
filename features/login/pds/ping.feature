@ping @selenium
Feature: PDS is running
  As a BobCat user,
  I want to be able to login
  So that I can save queries, items, etc.

  @production @partial_outage
  Scenario: Visiting PDS on production
    Then cURL visiting PDS should respond with success

  @production @degraded_performance
  Scenario: Visiting PDS LB server 1 on production
    Then cURL insecurely visiting PDS LB server 1 should respond with success

  @production @degraded_performance
  Scenario: Visiting PDS LB server 2 on production
    Then cURL insecurely visiting PDS LB server 2 should respond with success

  @staging @partial_outage
  Scenario: Visiting PDS on staging
    Then cURL visiting PDS staging should respond with success

  @staging @degraded_performance
  Scenario: Visiting PDS LB server 1 on staging
    Then cURL insecurely visiting PDS staging LB server 1 should respond with success

  @staging @degraded_performance
  Scenario: Visiting PDS LB server 2 on staging
    Then cURL insecurely visiting PDS staging LB server 2 should respond with success
