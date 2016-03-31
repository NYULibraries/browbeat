#@selenium
Feature: BobCat is running
  As an admin
  In order to maintain happy customers
  I want to ensure that my catalog always functions as expected.

  @ping
  Scenario: Ping BobCat "http://bobcatdev.library.nyu.edu"
    Given I visit "http://bobcatdev.library.nyu.edu"
    Then my browser should respond with a success
    And my browser should resolve to BobCat

  @functionality
  Scenario: Check BobCat's ability to execute a simple search
    Given I visit "http://bobcatdev.library.nyu.edu"
    When I search for "catcher in the rye"
    Then I should see results
