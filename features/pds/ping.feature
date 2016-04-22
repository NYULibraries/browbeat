@ping
Feature: PDS is running
  As a BobCat user,
  I want to be able to login
  So that I can save queries, items, etc.

  @production @partial_outage
  Scenario: Visiting PDS on production
    Given I visit PDS
    Then my browser should redirect to Login

  @production @degraded_performance
  Scenario: Visiting PDS LB server 1 on production
    Given I visit PDS LB server 1
    Then my browser should redirect to Login

  @production @degraded_performance
  Scenario: Visiting PDS LB server 2 on production
    Given I visit PDS LB server 2
    Then my browser should redirect to Login

  @staging @partial_outage
  Scenario: Visiting PDS on staging
    Given I visit PDS staging
    Then my browser should redirect to Login staging

  @staging @degraded_performance
  Scenario: Visiting PDS LB server 1 on staging
    Given I visit PDS staging LB server 1
    Then my browser should redirect to Login staging

  @staging @degraded_performance
  Scenario: Visiting PDS LB server 2 on staging
    Given I visit PDS staging LB server 2
    Then my browser should redirect to Login staging
