@ping @selenium
Feature: Login is running
  As a NYU Libraries user
  I want to be able to single-sign-on to Libraries' application
  So that I can maintain a persistent session.

  @production @major_outage
  Scenario: Visiting Login on production
    Then cURL visiting Login should respond with success

  @production @degraded_performance
  Scenario: Visiting Login LB server 1 on production
    Then cURL visiting Login LB server 1 should redirect to Login LB server 1 secure

  @production @degraded_performance
  Scenario: Visiting Login LB server 2 on production
    Then cURL visiting Login LB server 2 should redirect to Login LB server 2 secure

  @staging @major_outage
  Scenario: Visiting Login on staging
    Then cURL visiting Login staging should respond with success
