@ping @selenium
Feature: Rooms is running

  @production @warning @no_sauce
  Scenario: ElasticSearch on production
    Given I secretly visit Rooms ElasticSearch
    Then my browser should respond with a success for ElasticSearch
