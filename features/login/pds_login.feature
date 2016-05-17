@functionality @selenium
Feature: PDS is running
  As a BobCat user,
  I want to be able to login
  So that I can save queries, items, etc.

  @production @partial_outage
  Scenario: Logging in on production PDS
    Given I visit PDS
    When I login as an NYU user
    Then I should be logged in

  @production @partial_outage
  Scenario: Logging in on staging PDS
    Given I visit PDS staging
    When I login as an NYU staging user
    Then I should be logged in
