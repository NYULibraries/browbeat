@ping @selenium
Feature: e-Shelf is running
  As a NYU Libraries user,
  I want to be able to save items to my e-Shelf
  So that I can come back later and have a record of my research items.

  @production @major_outage
  Scenario: Visiting e-Shelf on production
    Then cURL visiting e-Shelf should respond with success

  @production @degraded_performance
  Scenario: Visiting e-Shelf LB server 1 on production
    Then cURL insecurely visiting e-Shelf LB server 1 should respond with success

  @production @degraded_performance
  Scenario: Visiting e-Shelf LB server 2 on production
    Then cURL insecurely visiting e-Shelf LB server 2 should respond with success

  @staging @major_outage
  Scenario: Visiting e-Shelf on staging
    Then cURL visiting e-Shelf staging should respond with success
