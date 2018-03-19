@ping @selenium
Feature: Rooms is running

  @production @major_outage
  Scenario: Visiting Rooms on production
    Given I visit Rooms
      Then my browser should resolve to Login
    When I login as an NYU user
      Then my browser should respond with a success for Rooms
      And my browser should resolve to Rooms

  @production @major_outage
  Scenario: Visiting Rooms on staging
    Given I visit Rooms staging
      Then my browser should resolve to Login staging
    When I login as an NYU staging user
      Then my browser should respond with a success for Rooms
      And my browser should resolve to Rooms staging
