@ping @selenium
Feature: Export citations is running
  As a researcher,
  I want to be able to export my citation from the catalog directly into a citation management tool
  So that I can keep my bibliography in order.

  @production @partial_outage
  Scenario: Exporting citations on production
    Given I visit BobCat export citation link
    Then I should download an ".openurl" file

  @staging @partial_outage @wip
  Scenario: Exporting citations on staging
    Given I visit BobCat staging export citation link
    Then I should download an ".openurl" file
