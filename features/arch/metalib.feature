@ping @selenium
Feature: Arch is running
  As an Arch user,
  I want to be able to find  databases in curated categories
  So that I can conduct my research efficiently.

  @production @warning
  Scenario: Visiting MetaLib on production
    Given I visit MetaLib
    Then my browser should respond with a success for MetaLib
    And my browser should resolve to MetaLib

  @production @partial_outage
  Scenario: Visiting MetaLib X-Server on production
    Given I visit MetaLib X-Server
    Then I should see valid XML with "error_code" node value "2004"
