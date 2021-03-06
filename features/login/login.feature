@functionality @selenium
Feature: Login is running
  As a NYU Libraries user
  I want to be able to single-sign-on to Libraries' application
  So that I can maintain a persistent session.

  @production @major_outage @no_sauce @login_required
  Scenario: Logging in on production
    Given I visit Login
    When I click on NYU Shibboleth link
    And I enter NYU credentials
    And I click "Continue" if prompted
    Then I should be logged in

  @staging @major_outage  @login_required
  Scenario: Logging in on staging
    Given I visit Login staging
    When I click on NYU Shibboleth link
    And I enter NYU staging credentials
    And I click "Continue" if prompted
    Then I should be logged in
