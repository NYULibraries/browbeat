@ping @selenium
Feature: Arch is running
  As an Arch user,
  I want to be able to find  databases in curated categories
  So that I can conduct my research efficiently.

  @production @major_outage
  Scenario: Visiting LibGuides
    Then cURL insecurely visiting Arch should respond with success
