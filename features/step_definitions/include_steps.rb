begin
  require 'rspec/expectations'
rescue LoadError
  require 'spec/expectations'
end
require 'cucumber/formatter/unicode'

$:.unshift(File.dirname(__FILE__) + '/../../lib')

###

require 'yaml_extras'
require 'fileutils'
require 'yaml'

Before do
  @yaml_extras = nil
  @work_dir = "work_dir"
  FileUtils.mkdir_p File.expand_path(@work_dir)
end

After do
  if File.exists?(@work_dir) and File.directory?(@work_dir)
    FileUtils.rm_rf @work_dir
  end
end

###

Given /^a file named "([^"]*)" containing:$/ do |name, string|
  full_path = File.join(@work_dir, name)
  File.open(full_path, 'w') do |f|
    f.write(string)
  end
end

When /^the file "([^"]*)" is processed$/ do |name|
  @yaml_extras = YamlExtras.new(File.join(@work_dir, name))
end

Then /^the result should be:$/ do |string|
  expected = YAML.load(string)
  @yaml_extras.result.should == expected
end
