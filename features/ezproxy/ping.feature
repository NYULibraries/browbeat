@ping @selenium
Feature: EZProxy is running
  As an off-campus user,
  I want to be able to access subscription databases
  So that I have access to NYU's resources regardless of my location.

  @production @warning @no_sauce @login_required
  Scenario: Visiting EZProxy on production
    Then cURL visiting EZProxy should redirect to "https://login.proxy.library.nyu.edu/login"

  @staging @warning @login_required
  Scenario: Visiting EZProxy on staging
    Then cURL visiting EZProxy staging should redirect to "https://login.proxydev.library.nyu.edu/login"
