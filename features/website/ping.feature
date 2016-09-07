@ping @selenium
Feature: Website is running
  As a Bobst user,
  I want to be able to search the Library catalog from the website homepage.

  @major_outage @production
  Scenario: Visiting Website on production
    Given I visit Website
    Then my browser should respond with a success for website
    And my browser should resolve to Website

  @major_outage @staging
  Scenario: Visiting Website on staging
    Given I visit Website staging
    Then my browser should respond with a success for website
    And my browser should resolve to Website staging
