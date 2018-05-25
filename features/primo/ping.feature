@ping @selenium
Feature: Primo is running
  As a BobCat user
  In order to know whether or not I can do my research today
  I want to be informed about the application's status.

  @production @major_outage
  Scenario: Visiting BobCat on production
    Then cURL visiting BobCat should respond with success

  @production @degraded_performance
  Scenario: Visiting BobCat LB server 1 on production
    Then cURL insecurely visiting BobCat LB server 1 should respond with success

  @production @degraded_performance
  Scenario: Visiting BobCat LB server 2 on production
    Then cURL insecurely visiting BobCat LB server 2 should respond with success

  @production @warning
  Scenario: Visiting BobCat NYUSH on production
    Then cURL visiting BobCat NYUSH should respond with success

  @production @warning
  Scenario: Visiting BobCat NYUAD on production
    Then cURL visiting BobCat NYUAD should respond with success

  @staging @major_outage
  Scenario: Visiting BobCat on staging
    Then cURL visiting BobCat staging should respond with success

  @staging @degraded_performance
  Scenario: Visiting BobCat LB server 1 on staging
    Then cURL insecurely visiting BobCat staging LB server 1 should respond with success


  @staging @degraded_performance
  Scenario: Visiting BobCat LB server 2 on staging
    Then cURL insecurely visiting BobCat staging LB server 2 should respond with success
