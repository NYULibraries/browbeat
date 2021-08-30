@ping @selenium
Feature: Special Collections is running
  As an Archival Collections user,
  I'd like to be able to search the finding aids for a collection
  So that I know what to ask for when I visit a special collection library such as Tamiment.

  @production @warning @no_sauce
  Scenario: WebSolr on production
    Then cURL secretly visiting Special Collections WebSolr should respond with success
