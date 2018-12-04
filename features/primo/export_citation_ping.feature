@ping @selenium
Feature: Export citations is running
  As a researcher,
  I want to be able to export my citation from the catalog directly into a citation management tool
  So that I can keep my bibliography in order.

  @production @partial_outage
  Scenario: Exporting citations on production
    Then cURL visiting BobCat staging export citation link should respond with a "Content-Type" header containing the value "application/json"

  @staging @partial_outage
  Scenario: Exporting citations on staging
    Then cURL visiting BobCat staging export citation link should respond with a "Content-Type" header containing the value "application/json"
