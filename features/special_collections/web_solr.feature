@ping @selenium
Feature: Special Collections is running
  As an Archival Collections user,
  I'd like to be able to search the finding aids for a collection
  So that I know what to ask for when I visit a special collection library such as Tamiment.

  @production @major_outage
  Scenario: WebSolr on production
    Given I secretly visit WebSolr
    Then my browser should respond with a success for WebSolr
