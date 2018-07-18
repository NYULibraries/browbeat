@ping @selenium
Feature: Privileges is running
  As a Bobst user,
  I want to be able to search for my privileges
  So that I know what I can do with various services.

  @production @warning @no_sauce
  Scenario: WebSolr on production
    Then cURL secretly visiting Privileges WebSolr should respond with success
