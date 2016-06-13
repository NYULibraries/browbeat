@functionality @selenium
Feature: ILLiad is running
  As a Bobst user,
  I want to be able to get a book from Interlibrary Loan even if Bobst doesn't have it
  So that I don't have to delay my research.

  @major_outage @production @wip
  Scenario: Visiting ILLiad on production
    Given I login as an NYU user
    And I visit ILLiad request sample
    Then I should see "Test title" in the "Title" field

  @major_outage @staging @wip
  Scenario: Visiting ILLiad on staging
    Given I login as an NYU staging user
    And I visit ILLiad staging request sample
    Then I should see "Test title" in the "Title" field
