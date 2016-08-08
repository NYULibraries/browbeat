@ping @selenium
Feature: Arch is running
  As an Arch user,
  I want to be able to find  databases in curated categories
  So that I can conduct my research efficiently.

  @production @major_outage
  Scenario: Visiting Arch on production
    Given I visit Arch
    Then my browser should respond with a success for Arch
    And my browser should resolve to Arch

  @production @warning
  Scenario: Visiting Arch NYUSH on production
    Given I visit Arch NYUSH
    Then my browser should respond with a success for Arch
    And my browser should resolve to Arch NYUSH

  @staging @major_outage
  Scenario: Visiting Arch on staging
    Given I visit Arch staging
    Then my browser should respond with a success for Arch
    And my browser should resolve to Arch staging

  @staging @major_outage
  Scenario: Visiting Arch on staging QA
    Given I visit Arch QA
    Then my browser should respond with a success for Arch
    And my browser should resolve to Arch QA
