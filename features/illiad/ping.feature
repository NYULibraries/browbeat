@ping @selenium
Feature: ILLiad is running
  As a Bobst user,
  I want to be able to get a book from Interlibrary Loan even if Bobst doesn't have it
  So that I don't have to delay my research.

  @major_outage @production @wip
  Scenario: Visiting ILLiad on production
    Given I visit ILLiad
    Then my browser should respond with a success for Login
    And my browser should resolve to Login

  @major_outage @staging @wip
  Scenario: Visiting ILLiad on staging
    Given I visit ILLiad staging
    Then my browser should respond with a success for Login
    And my browser should resolve to Login staging
