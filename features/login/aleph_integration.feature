@functionality @selenium
Feature: Login is running
  As a NYU Libraries user
  I want to be able to single-sign-on to Libraries' application
  So that I can maintain a persistent session.

  Scenario: Logging in on production via X-services
    Given I visit X-services sample
    Then I should see valid XML without "error" node

  Scenario: Logging in on staging via X-services
    Given I visit X-services sample staging
    Then I should see valid XML without "error" node
