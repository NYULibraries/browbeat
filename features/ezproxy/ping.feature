@ping @selenium
Feature: EZProxy is running
  As an off-campus user,
  I want to be able to access subscription databases
  So that I have access to NYU's resources regardless of my location.

  @production @major_outage @no_sauce @login_required
  Scenario: Visiting EZProxy on production
    Given I visit EZProxy
      Then my browser should resolve to Login
    When I login as an NYU user
      Then I should see a link with href containing "www.jstor.org"
      And my browser should resolve to EZProxy

  @staging @major_outage @login_required
  Scenario: Visiting EZProxy on staging
    Given I visit EZProxy staging
      Then my browser should resolve to Login staging
    When I login as an NYU staging user
      Then I should see a link with href containing "www.jstor.org"
      And my browser should resolve to EZProxy staging
