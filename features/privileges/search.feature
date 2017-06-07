@functionality @selenium
Feature: Privileges is running
  As a Bobst user,
  I want to be able to search for my privileges
  So that I know what I can do with various services.

  @production @major_outage
  Scenario: Searching for Friends privileges on production
    Given I visit Privileges
    When I search privileges for "Friends"
      Then I should see a guide for "Friends of Bobst Library"
    When I select "NYU Bobst" from the privileges dropdown
      Then I should expect to see a privileges table

  @staging @major_outage
  Scenario: Searching for Friends privileges on staging
    Given I visit Privileges staging
    When I search privileges for "Friends"
      Then I should see a guide for "Friends of Bobst Library"
    When I select "NYU Bobst" from the privileges dropdown
      Then I should expect to see a privileges table
