@ping @selenium
Feature: Privileges is running
  As a Bobst user,
  I want to be able to search for my privileges
  So that I know what I can do with various services.

  @production @major_outage
  Scenario: Visiting Privileges on production
    Then cURL visiting Privileges should respond with success


  @staging @major_outage
  Scenario: Visiting Privileges on staging
    Then cURL visiting Privileges staging should respond with success
