@ping @selenium
Feature: EZBorrow is running
  As a Bobst user,
  I want to be able to get a book from EZBorrow even if Bobst doesn't have it
  So that I don't have to delay my research.

  @major_outage @production
  Scenario: Visiting EZBorrow on production
    Given I visit EZBorrow
      Then my browser should resolve to Login
    When I login as an NYU user
      Then my browser should respond with a success for EZBorrow
      And my browser should resolve to EZBorrow
