@ping @selenium
Feature: Arch is running
  As an Arch user,
  I want to be able to find  databases in curated categories
  So that I can conduct my research efficiently.

  @production @major_outage
  Scenario: Visiting Salon
    Then cURL visiting Salon false ID should respond with 400

  @staging @major_outage
  Scenario: Visiting Salon staging
    Then cURL visiting Salon staging false ID should respond with 400
