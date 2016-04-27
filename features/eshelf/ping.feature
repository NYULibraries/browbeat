@ping @selenium
Feature: e-Shelf is running
  As a NYU Libraries user,
  I want to be able to save items to my e-Shelf
  So that I can come back later and have a record of my research items.

  @production @major_outage
  Scenario: Visiting e-Shelf on production
    Given I visit e-Shelf
    Then my browser should respond with a success
    And my browser should resolve to e-Shelf

  @production @degraded_performance
  Scenario: Visiting e-Shelf LB server 1 on production
    Given I visit e-Shelf LB server 1
    Then my browser should respond with a success
    And my browser should redirect to passive Login

  @production @degraded_performance
  Scenario: Visiting e-Shelf LB server 2 on production
    Given I visit e-Shelf LB server 2
    Then my browser should respond with a success
    And my browser should redirect to passive Login

  @staging @major_outage
  Scenario: Visiting e-Shelf on staging
    Given I visit e-Shelf staging
    Then my browser should respond with a success
    And my browser should resolve to e-Shelf staging

  @staging @major_outage
  Scenario: Visiting e-Shelf on staging QA
    Given I visit e-Shelf QA
    Then my browser should respond with a success
    And my browser should resolve to e-Shelf QA
