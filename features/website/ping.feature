@ping @selenium
Feature: Website is running
  As a Bobst user,
  I want to be able to search the Library catalog from the website homepage.

  @ping @production
  Scenario: Visiting Website on production
    Given I visit Website
    Then my browser should respond with a success for website
    And my browser should resolve to Website

  @ping @staging
  Scenario: Visiting Website on beta
    Given I visit Website beta
    Then my browser should respond with a success for website
    And my browser should resolve to Website beta

  @ping @staging
  Scenario: Visiting Website on staging
    Given I visit Website staging
    Then my browser should respond with a success for website
    And my browser should resolve to Website staging
