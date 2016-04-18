@ping
Feature: Primo is running
  As a BobCat user
  In order to know whether or not I can do my research today
  I want to be informed about the application's status.

  @production @major_outage
  Scenario: Visiting BobCat on production
    Given I visit BobCat
    Then my browser should respond with a success
    And my browser should resolve to BobCat

  @production @degraded_performance
  Scenario: Visiting BobCat LB server 1 on production
    Given I visit BobCat LB server 1
    Then my browser should respond with a success
    And my browser should resolve to BobCat

  @production @degraded_performance
  Scenario: Visiting BobCat LB server 2 on production
    Given I visit BobCat LB server 2
    Then my browser should respond with a success
    And my browser should resolve to BobCat

  @staging @major_outage
  Scenario: Visiting BobCat on staging
    Given I visit BobCat staging
    Then my browser should respond with a success
    And my browser should resolve to BobCat

  @staging @degraded_performance
  Scenario: Visiting BobCat LB server 1 on staging
    Given I visit BobCat staging LB server 1
    Then my browser should respond with a success
    And my browser should resolve to BobCat

  @staging @degraded_performance
  Scenario: Visiting BobCat LB server 2 on staging
    Given I visit BobCat staging LB server 2
    Then my browser should respond with a success
    And my browser should resolve to BobCat
