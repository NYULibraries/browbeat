@ping @selenium
Feature: MaRLi is running
  As a graduate researcher,
  I want to be able to register for the MaRLi program
  So that I can get resources from Columbia and the NYPL.

  @ping @production
  Scenario: Visiting MaRLi on production
    Given I visit MaRLi
    Then my browser should respond with a success for Login
    And my browser should resolve to Login

  @ping @staging @wip
  Scenario: Visiting MaRLi on staging
    Given I visit MaRLi staging
    Then my browser should respond with a success for Login
    And my browser should resolve to Login staging
