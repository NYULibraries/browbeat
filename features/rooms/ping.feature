@ping @selenium
Feature: Rooms is running

  @production @major_outage @wip
  Scenario: Visiting Rooms on production
    Then cURL visiting Rooms should respond with success

  @staging @major_outage @wip
  Scenario: Visiting Rooms on staging
    Then cURL visiting Rooms staging should respond with success
