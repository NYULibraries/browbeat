@ping @selenium
Feature: Privileges is running
  As a Bobst user,
  I want to be able to search for my privileges
  So that I know what I can do with various services.

  @production @major_outage
  Scenario: Visiting Privileges on production
    Given I visit Privileges
    Then my browser should respond with a success for Privileges
    And my browser should resolve to Privileges

  @staging @major_outage
  Scenario: Visiting Privileges on staging
    Given I visit Privileges staging
    Then my browser should respond with a success for Privileges
    And my browser should resolve to Privileges staging
