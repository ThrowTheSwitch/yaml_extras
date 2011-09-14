begin
  require 'rspec/expectations'
rescue LoadError
  require 'spec/expectations'
end
require 'cucumber/formatter/unicode'

$:.unshift(File.dirname(__FILE__) + '/../../lib')

###

require 'yaml_extras'
require 'tmpdir'
require 'fileutils'
require 'yaml'

def read_yaml(f)
  YAML.load(File.read(f))
end

Before do
  @yaml_extras = nil
  @tmpdir = Dir.tmpdir + "/cuke_tempdir"
end

After do
  if File.exists?(@tmpdir) and File.directory?(@tmpdir)
    FileUtils.rm_rf @tmpdir
  end
end

###

Given /^a directory$/ do
  Dir.mkdir @tmpdir
end

Given /^a file named "([^"]*)" in the directory containing:$/ do |name, string|
  File.open("#{@tmpdir}/#{name}", 'w') do |f|
    f.write(string)
  end
end

When /^the file "([^"]*)" is evaluated$/ do |name|
  @yaml_extras = YamlExtras.new(name)
end

Then /^the result contains the data from "([^"]*)" in "([^"]*)" at the level of INCLUDE$/ do |other, main|
  pending # express the regexp above with the code you wish you had
end

Then /^the INCLUDE key is deleted$/ do
  pending # express the regexp above with the code you wish you had
end
