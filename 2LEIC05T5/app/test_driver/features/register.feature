Feature: Login
  As a non-registered user, I want to be able to create an account so that I can personalize my experience and access all features.

#  Scenario: Successful Account Registration
#    Given User on the login page
#    When User tap "Sign Up" button
#    And User fill in "UsernameTextField" "mansur2"
#    And User fill in "EmailTextField" "mansur2@gmail.com"
#    And User fill in "PasswordTextField" "qwerty"
#    And User fill in "ConfirmPasswordTextField" "qwerty"
#    And User tap "Register" button
#    Then User will be redirected to main page

  Scenario: Failed Registration with Email Already in Use
    Given User on the login page
    When User tap "Sign Up" button
    And User fill in "UsernameTextField" "mansur"
    And User fill in "EmailTextField" "mansur1@gmail.com"
    And User fill in "PasswordTextField" "qwerty"
    And User fill in "ConfirmPasswordTextField" "qwerty"
    And User tap "Register" button
    Then User will see 'The email address is already in use by another account.'

  Scenario: Failed Registration with Missing Username
    Given User on the login page
    When User tap "Sign Up" button
    And User fill in "UsernameTextField" ""
    And User fill in "EmailTextField" "mansur1@gmail.com"
    And User fill in "PasswordTextField" "qwerty"
    And User fill in "ConfirmPasswordTextField" "qwerty"
    And User tap "Register" button
    Then User will see 'Please enter all the fields'

  Scenario: Failed Registration with Missing Email
    Given User on the login page
    When User tap "Sign Up" button
    And User fill in "UsernameTextField" "mansur"
    And User fill in "EmailTextField" ""
    And User fill in "PasswordTextField" "qwerty"
    And User fill in "ConfirmPasswordTextField" "qwerty"
    And User tap "Register" button
    Then User will see 'Please enter all the fields'

  Scenario: Failed Registration with Non-Matching Passwords
    Given User on the login page
    When User tap "Sign Up" button
    And User fill in "UsernameTextField" "mansur"
    And User fill in "EmailTextField" "mansur@gmail.com"
    And User fill in "PasswordTextField" "123"
    And User fill in "ConfirmPasswordTextField" "123"
    And User tap "Register" button
    Then User will see 'Password too weak.'

  Scenario: Failed Registration with Invalid Email Format
    Given User on the login page
    When User tap "Sign Up" button
    And User fill in "UsernameTextField" "mansur"
    And User fill in "EmailTextField" "mansur@"
    And User fill in "PasswordTextField" "qwerty"
    And User fill in "ConfirmPasswordTextField" "qwerty"
    And User tap "Register" button
    Then User will see 'Invalid email format.'

  Scenario: Failed Registration with Non-Matching Passwords
    Given User on the login page
    When User tap "Sign Up" button
    And User fill in "UsernameTextField" "mansur1"
    And User fill in "EmailTextField" "mansur1@gmail.com"
    And User fill in "PasswordTextField" "qwerty1"
    And User fill in "ConfirmPasswordTextField" "qwerty2"
    And User tap "Register" button
    Then User will see 'Passwords don't match'