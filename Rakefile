require 'bundler'
include Rake::DSL

Bundler::GemHelper.install_tasks

require 'rake/testtask'
Rake::TestTask.new("test") do |test|
  test.pattern = "test/**/*_test.rb"
  test.verbose = true
end
