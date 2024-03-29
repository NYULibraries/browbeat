@ping @selenium
Feature: ILLiad is running
  As a Bobst user,
  I want to be able to get a book from Interlibrary Loan even if Bobst doesn't have it
  So that I don't have to delay my research.

  @major_outage @production
  Scenario: Visiting ILLiad on production
    Then cURL visiting ILLiad should redirect to "https://login.library.nyu.edu/logout/illiad"

  @major_outage @staging @wip
  Scenario: Visiting ILLiad on staging
    Then cURL visiting ILLiad staging should redirect to "https://dev.login.library.nyu.edu"
