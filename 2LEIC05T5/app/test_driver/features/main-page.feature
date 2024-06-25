Feature: Main page
  As a user I want to be able to see all events that I'm enrolled in so that I can easily access their information.

  Scenario: See events
    Given User on main page
    When User fill in "SearchFiled" "rio"
    Then User will see "Recolha de lixo do rio"
