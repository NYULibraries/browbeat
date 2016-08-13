@ping @selenium
Feature: Special Collections is running
  As an Archival Collections user,
  I'd like to be able to search the finding aids for a collection
  So that I know what to ask for when I visit a special collection library such as Tamiment.

  @production @major_outage
  Scenario: Visiting Special Collections on production
    Given I visit Special Collections
    Then my browser should respond with a success for Special Collections
    And my browser should resolve to Special Collections

  @production @degraded_performance @wip
  Scenario: Visiting Special Collections LB server 1 on production
    Given I visit Special Collections LB server 1
    Then my browser should redirect to Login authorization page

  @production @degraded_performance @wip
  Scenario: Visiting Special Collections LB server 2 on production
    Given I visit Special Collections LB server 2
    Then my browser should redirect to Login authorization page

  @staging @major_outage @wip
  Scenario: Visiting Special Collections on staging
    Given I visit Special Collections staging
    Then my browser should respond with a success for Special Collections
    And my browser should resolve to Special Collections staging
