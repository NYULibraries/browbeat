@ping @selenium
Feature: Export citations is running
  As a researcher,
  I want to be able to export my citation from the catalog directly into a citation management tool
  So that I can keep my bibliography in order.

  @production @partial_outage
  Scenario: Exporting citations on production
    Given I visit BobCat
    When I search for "hamlet"
    And I select the first multi-version record
    And I select "EasyBIB" from the "Send/Share" psuedo-dropdown in the first result
    Then I should see an EasyBib record "Hamlet" in a new window

  @staging @partial_outage
  Scenario: Exporting citations on staging
    Given I visit BobCat staging
    When I search for "hamlet"
    And I select the first multi-version record
    And I select "EasyBIB" from the "Send/Share" psuedo-dropdown in the first result
    Then I should see an EasyBib record "Hamlet" in a new window
