require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

task :version do
    p "v#{Docker::API::GEM_VERSION}"
end
