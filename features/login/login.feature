@functionality @selenium
Feature: Login is running
  As a NYU Libraries user
  I want to be able to single-sign-on to Libraries' application
  So that I can maintain a persistent session.

  @production @major_outage
  Scenario: Logging in on production
    Given I visit Login
    When I login as an NYU user
    Then I should be logged in

  @staging @major_outage
  Scenario: Logging in on staging
    Given I visit Login staging
    When I login as an NYU staging user
    Then I should be logged in
