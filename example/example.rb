$: << '../lib'
require 'yaml_extras'

puts YamlExtras.new("main.yml").result.to_yaml
