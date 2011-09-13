# language: en
Feature: Include
	In order to simplify configuration data
	As a devloper using YAML to configure an application
	I want to be able to include the structure of one YAML file in another

	Scenario: Include external file
		Given a directory
		And a file named "main.yml" in the directory containing:
			"""
			---
				a: 0
				INCLUDE: external.yaml
			"""
		And a file named "external.yml" in the directory containing:
			"""
			---
				b: 1
			"""
		Then the result contains the data from "external.yml" in "main.yml" at the level of INCLUDE
		And the INCLUDE key is deleted
