# temp fix for NoMethodError: undefined method `last_comment'
# remove when fixed in Rake 11.x
module TempFixForRakeLastComment
  def last_comment
    last_description
  end
end
Rake::Application.send :include, TempFixForRakeLastComment
### end of temfix

require 'bundler/gem_tasks'
require 'rspec/core'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

task default: 'spec:all'

namespace :spec do
  %w(rails_42 rails_41 rails_40 rails_32).each do |gemfile|
    desc "Run Tests against #{gemfile}"
    task gemfile do
      sh "BUNDLE_GEMFILE='gemfiles/#{gemfile}.gemfile' bundle --quiet"
      sh "BUNDLE_GEMFILE='gemfiles/#{gemfile}.gemfile' bundle exec rake spec"
    end
  end

  desc "Run Tests against rails versions"
  task :all do
    %w(rails_42 rails_41 rails_40 rails_32).each do |gemfile|
      sh "BUNDLE_GEMFILE='gemfiles/#{gemfile}.gemfile' bundle --quiet"
      sh "BUNDLE_GEMFILE='gemfiles/#{gemfile}.gemfile' bundle exec rake spec"
    end
  end
end
