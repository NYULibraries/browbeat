@interface @selenium
Feature: Primo is running
  As a BobCat user
  In order to know whether or not I can do my research today
  I want to be informed about the application's status.

  @production @major_outage
  Scenario: Viewing BobCat interface on production
    Given I visit BobCat
    Then I should see the tabbed interface
    And I should see the Libraries' logo

  @staging @major_outage @wip
  Scenario: Viewing BobCat interface on staging
    Given I visit BobCat staging
    Then I should see the tabbed interface
    And I should see the Libraries' logo
