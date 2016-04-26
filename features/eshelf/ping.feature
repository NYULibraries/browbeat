@ping @selenium
Feature: E-shelf is running
  As a NYU Libraries user,
  I want to be able to save items to my E-shelf
  So that I can come back later and have a record of my research items.

  @production @major_outage
  Scenario: Visiting E-shelf on production
    Given I visit E-shelf
    Then my browser should respond with a success
    And my browser should resolve to E-shelf

  @production @degraded_performance
  Scenario: Visiting E-shelf LB server 1 on production
    Given I visit E-shelf LB server 1
    Then my browser should respond with a success
    And my browser should redirect to passive Login

  @production @degraded_performance
  Scenario: Visiting E-shelf LB server 2 on production
    Given I visit E-shelf LB server 2
    Then my browser should respond with a success
    And my browser should redirect to passive Login

  @staging @major_outage
  Scenario: Visiting E-shelf on staging
    Given I visit E-shelf staging
    Then my browser should respond with a success
    And my browser should resolve to E-shelf staging

  @staging @major_outage
  Scenario: Visiting E-shelf on staging QA
    Given I visit E-shelf QA
    Then my browser should respond with a success
    And my browser should resolve to E-shelf QA
