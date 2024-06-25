Feature: Login
  As a registered user, I am required to log in so that I can access the system.

  Scenario: Successful Account Login
    Given User on the login page
    When User fill in "EmailTextField" "mansur@gmail.com"
    And User fill in "PasswordTextField" "qwerty"
    And User tap "Sign In" button
    Then User will be redirected to main page

  Scenario: Failed Login with Incorrect Credentials
    Given User on the login page
    When User fill in "EmailTextField" "mansur@main.ru"
    And User fill in "PasswordTextField" "qwerty"
    And User tap "Sign In" button
    Then User will see "Wrong password or email"

  Scenario: Failed Login with Malformed Email Address
    Given User on the login page
    When User fill in "EmailTextField" "mansur@"
    And User fill in "PasswordTextField" "qwerty"
    And User tap "Sign In" button
    Then User will see "No user found for that email."

  Scenario: Failed Login with Missing Password
    Given User on the login page
    When User fill in "EmailTextField" "mansur@gmail.com"
    And User fill in "PasswordTextField" ""
    And User tap "Sign In" button
    Then User will see "Please enter all the fields"

  Scenario: Failed Login with Missing Email
    Given User on the login page
    When User fill in "EmailTextField" ""
    And User fill in "PasswordTextField" "qwerty"
    And User tap "Sign In" button
    Then User will see "Please enter all the fields"

  Scenario: Navigation login page
    Given User on the login page
    When User tap "Sign Up" button
    Then User will see "Register"

  Scenario: Navigation login page back
    Given User on the login page
    When User tap "Sign Up" button
    And User tap "Back" button
    Then User will see "Sign In"
