@functionality @selenium
Feature: Export citations is running
  As a researcher,
  I want to be able to export my citation from the catalog directly into a citation management tool
  So that I can keep my bibliography in order.

  @production @partial_outage @wip
  Scenario: Exporting citations on production
    Given I visit BobCat
    When I search for "hamlet" in the NUI
    And I select the first NUI multi-version record
    And I select the first NUI record
    And I click on "BIBTEX"

  @staging @partial_outage @wip
  Scenario: Exporting citations on staging
    Given I visit BobCat staging
    When I search for "hamlet" in the NUI
    And I select the first NUI multi-version record
    And I select the first NUI record
    And I click on "BIBTEX"
