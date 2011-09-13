# language: en
Feature: Include
	In order to simplify configuration data
	As a devloper using YAML to configure an application
	I want to be able to include the structure of one YAML file in another

	Scenario Outline: Include external file
		Given a YAML file named "main.yaml"
		And an external file named "external.yaml"
		When the file named "main.yaml" contains a key with the value "INCLUDE"
		And the key "INCLUDE" has a value of "external.yaml"
		Then the structure of "external.yaml" should be included as a sibling of the "INCLUDE" key
		And the "INCLUDE" key should be deleted
