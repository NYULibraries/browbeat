@ping @selenium
Feature: Rooms is running

  @production @warning @no_sauce @wip
  Scenario: ElasticSearch on production
    Then cURL secretly visiting Rooms ElasticSearch should respond with success
