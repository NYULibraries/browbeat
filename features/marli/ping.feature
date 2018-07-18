@ping @selenium
Feature: MaRLi is running
  As a graduate researcher,
  I want to be able to register for the MaRLi program
  So that I can get resources from Columbia and the NYPL.

  @major_outage @production @login_required
  Scenario: Visiting MaRLi on production
    Then cURL visiting MaRLi should respond with success

  @major_outage @staging @login_required
  Scenario: Visiting MaRLi on staging
    Then cURL visiting MaRLi staging should respond with success
