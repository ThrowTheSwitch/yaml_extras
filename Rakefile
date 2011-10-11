require "rspec/core/rake_task"
require "cucumber/rake/task"

Cucumber::Rake::Task.new(:cucumber)

desc "Run all examples"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = %w[--color]
end

task :default  => [:spec, :cucumber]
