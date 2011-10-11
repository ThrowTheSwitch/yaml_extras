# language: en
Feature: Include
  In order to simplify configuration data
  As a devloper using YAML to configure an application
  I want to be able to include the structure of one YAML file in another

  Scenario: Include external file
    Given a file named "main.yml" containing:
      """
      ---
        a: 0
        b:
          INCLUDE: external.yml
      """
    And a file named "external.yml" containing:
      """
      ---
        c: 1
      """
    When the file "main.yml" is processed
    Then the result should be:
      """
      ---
        a: 0
        b:
          c: 1
      """
