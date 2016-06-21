@feature @selenium
Feature: Arch is running
  As an Arch user,
  I want to be able to find  databases in curated categories
  So that I can conduct my research efficiently.

  @production @major_outage
  Scenario: Visiting JSTOR from Arch on production
    Given I visit Arch
    When I click on "Login"
    And I login as an NYU user
    And I click on "JSTOR"
    Then my browser should respond with a success for JSTOR

  @staging @major_outage
  Scenario: Visiting JSTOR from Arch on staging
    Given I visit Arch staging
    When I click on "Login"
    And I login as an NYU staging user
    And I click on "JSTOR"
    Then my browser should respond with a success for JSTOR

  @staging @major_outage
  Scenario: Visiting JSTOR from Arch on staging QA
    Given I visit Arch QA
    When I click on "Login"
    And I login as an NYU staging user
    And I click on "JSTOR"
    Then my browser should respond with a success for JSTOR
