@ping @selenium
Feature: EZBorrow is running
  As a Bobst user,
  I want to be able to get a book from EZBorrow even if Bobst doesn't have it
  So that I don't have to delay my research.

  @warning @production @no_sauce @login_required
  Scenario: Visiting EZBorrow on production
    Then cURL visiting EZBorrow should respond with success
