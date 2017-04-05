@functionality @selenium
Feature: EZProxy is running
  As an off-campus user,
  I want to be able to access subscription databases
  So that I have access to NYU's resources regardless of my location.

  @production @major_outage @no_sauce @login_required
  Scenario: Follow EZProxy link on production
    Given I visit EZProxy JSTOR link
    And I login as an NYU user if prompted
    Then I should see a JSTOR page

  @staging @major_outage @login_required
  Scenario: Follow EZProxy link on staging
    Given I visit EZProxy staging JSTOR link
    And I login as an NYU staging user if prompted
    Then I should see a JSTOR page
