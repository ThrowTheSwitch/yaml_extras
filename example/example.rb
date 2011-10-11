$: << '../lib'
require 'yaml_extras'

puts YamlExtras.new("top.yml").result.to_yaml
