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

Before do
  @yaml_extras = nil
  @tmpdir = Dir.tmpdir + "/cuke_tempdir"
  @files = {}
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
  full_path = File.join(@tmpdir, name)
  @files[name] = full_path
  File.open(full_path, 'w') do |f|
    f.write(string)
  end
end

When /^the file "([^"]*)" is processed$/ do |name|
  @yaml_extras = YamlExtras.new(@files[name])
end

Then /^the result should be:$/ do |string|
  expected = YAML.load(string)
  @yaml_extras.result.should == expected
end
