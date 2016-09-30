@functionality @selenium
Feature: PDS is running
  As a BobCat user,
  I want to be able to login
  So that I can save queries, items, etc.

  @production @partial_outage @no_sauce @login_required
  Scenario: Logging in on production PDS
    Given I visit PDS
    When I click on "NYU"
    And I enter NYU credentials
    And I click "Continue" if prompted
    Then I should be logged in

  @staging @partial_outage @login_required
  Scenario: Logging in on staging PDS
    Given I visit PDS staging
    When I click on "NYU"
    And I enter NYU staging credentials
    And I click "Continue" if prompted
    Then I should be logged in
