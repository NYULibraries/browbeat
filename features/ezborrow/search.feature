@functionality @selenium
Feature: EZBorrow is running
  As a Bobst user,
  I want to be able to get a book from EZBorrow even if Bobst doesn't have it
  So that I don't have to delay my research.

  @major_outage @production @no_sauce @login_required
  Scenario: Visiting EZBorrow on production
    Given I visit EZBorrow
    When I search EZBorrow for "digital divide"
    Then I should see EZBorrow results page
