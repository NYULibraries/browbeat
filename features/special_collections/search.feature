@functionality @selenium
Feature: Special Collections is running
  As an Archival Collections user,
  I'd like to be able to search the finding aids for a collection
  So that I know what to ask for when I visit a special collection library such as Tamiment.

  @production @major_outage
  Scenario: Searching on production
    Given I visit Special Collections
    When I search for "cuba" in Special Collections
    And I click on external link "Cuban Letters Collection"
    Then my browser should open a new window with finding aid base URL

  @staging @major_outage @wip
  Scenario: Searching on staging
    Given I visit Special Collections staging
    When I search for "cuba" in Special Collections
    And I click on external link "Cuban Letters Collection"
    Then my browser should open a new window with finding aid base URL
