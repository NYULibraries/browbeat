@feature @selenium
Feature: Arch is running
  As an Arch user,
  I want to be able to find  databases in curated categories
  So that I can conduct my research efficiently.

  @production @warning @no_sauce @login_required
  Scenario: Visiting JSTOR from Arch on production
    Given I visit Arch
    When I click on "Login"
    And I login as an NYU user
    And I click on "JSTOR"
    Then I should see a JSTOR page

  @staging @warning @login_required
  Scenario: Visiting JSTOR from Arch on staging
    Given I login as an NYU user
    And I visit Arch staging
    When I click on "JSTOR"
    Then I should see a JSTOR page

  @staging @warning @login_required
  Scenario: Visiting JSTOR from Arch on staging QA
    Given I login as an NYU user
    And I visit Arch QA
    When I click on "JSTOR"
    Then I should see a JSTOR page
