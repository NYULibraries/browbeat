@ping @selenium
Feature: Privileges is running
  As a Bobst user,
  I want to be able to search for my privileges
  So that I know what I can do with various services.

  @production @major_outage @no_sauce
  Scenario: WebSolr on production
    Given I secretly visit Privileges WebSolr
    Then my browser should respond with a success for WebSolr
