require 'bundler/gem_tasks'
Bundler.setup
require "rspec/core/rake_task"

desc "Run all examples"
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = %w[ --color ]
  t.verbose = false
end
