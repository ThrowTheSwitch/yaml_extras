begin
	require 'rspec/expectations'
rescue LoadError
	require 'spec/expectations'
end
require 'cucumber/formatter/unicode'

$:.unshift(File.dirname(__FILE__) + '/../../lib')
require 'yaml_extras'

Before do
	@yaml_extras = YamlExtras.new
end

After do
end
