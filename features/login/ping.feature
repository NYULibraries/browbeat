@ping @selenium
Feature: Login is running
  As a NYU Libraries user
  I want to be able to single-sign-on to Libraries' application
  So that I can maintain a persistent session.

  @production @major_outage
  Scenario: Visiting Login on production
    Given I visit Login
    Then my browser should respond with a success
    And my browser should resolve to Login

  @production @degraded_performance
  Scenario: Visiting Login LB server 1 on production
    Given I visit Login LB server 1
    Then my browser should respond with a success
    And my browser should resolve to Login

  @production @degraded_performance
  Scenario: Visiting Login LB server 2 on production
    Given I visit Login LB server 2
    Then my browser should respond with a success
    And my browser should resolve to Login

  @staging @major_outage
  Scenario: Visiting Login on staging
    Given I visit Login staging
    Then my browser should respond with a success
    And my browser should resolve to Login
