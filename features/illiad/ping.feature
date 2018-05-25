@ping @selenium
Feature: ILLiad is running
  As a Bobst user,
  I want to be able to get a book from Interlibrary Loan even if Bobst doesn't have it
  So that I don't have to delay my research.

  @major_outage @production
  Scenario: Visiting ILLiad on production
    Then cURL visiting ILLiad should redirect to Login

  @major_outage @staging
  Scenario: Visiting ILLiad on staging
    Then cURL visiting ILLiad staging should redirect to Login staging
